//
//  Ez_UnzipApp.swift
//  Ez Unzip
//
//  Created by kkxx on 2024/11/27.
//

import KeyboardShortcuts
import SwiftUI

@main
struct Ez_UnzipApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var mainWindow: NSWindow?
    var settingsWindowController: NSWindowController?
    var aboutWindowController: NSWindowController?
    var taskHelper = TaskHelper.shard

    func applicationWillFinishLaunching(_ notification: Notification) {
        toggleDockIconVisibility(show: UserDefaults.standard.isShowDocIcon())
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "archivebox", accessibilityDescription: nil)
        }
        setupMenu()
        setupGlobalShortcuts()
    }

    func createMenuItem(imageName: String, action: Selector, keyEquivalent: String = "", modifierMask: NSEvent.ModifierFlags = []) -> NSMenuItem {
        let menuItem = NSMenuItem()
        menuItem.image = NSImage(systemSymbolName: imageName, accessibilityDescription: nil)
        menuItem.action = action
        menuItem.target = self
        menuItem.title = ""

        menuItem.keyEquivalent = keyEquivalent
        menuItem.keyEquivalentModifierMask = modifierMask
        return menuItem
    }

    @MainActor func createMenuItem(imageName: String, action: Selector, string name: KeyboardShortcuts.Name) -> NSMenuItem {
        let menuItem = NSMenuItem()
        menuItem.image = NSImage(systemSymbolName: imageName, accessibilityDescription: nil)
        menuItem.action = action
        menuItem.target = self
        menuItem.title = ""
        menuItem.setShortcut(for: name)
        return menuItem
    }

    @MainActor func setupMenu() {
        let menu = NSMenu()
//        menu.addItem(createMenuItem(imageName: "macwindow", action: #selector(openMainWindow), string: .openMain))
        menu.addItem(createMenuItem(imageName: "gear", action: #selector(openSettingsWindow), string: .openSetting))
        menu.addItem(createMenuItem(imageName: "a.circle", action: #selector(openAboutWindow), string: .openAbout))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(createMenuItem(imageName: "power", action: #selector(quitApp), string: .quit))
        statusItem.menu = menu
    }

    func setupMainWindow() {
        let mainView = ContentView()
        let hostingController = NSHostingController(rootView: mainView)
        mainWindow = NSWindow(
            contentViewController: hostingController
        )
        mainWindow?.title = "Ez Unzip"
        mainWindow?.setContentSize(NSSize(width: 600, height: 400))
        mainWindow?.styleMask = [.titled, .closable, .resizable, .miniaturizable]
    }

    @objc func openMainWindow() {
        if mainWindow == nil {
            setupMainWindow()
        }
        if let mainWindow = mainWindow {
            centerWindow(mainWindow)
            mainWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true) // 激活应用
        }
    }

    @objc func openSettingsWindow() {
        if let windowController = settingsWindowController {
            windowController.showWindow(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView()
        let hostingController = NSHostingController(rootView: settingsView)
        let window = NSWindow(
            contentViewController: hostingController
        )
        window.title = "Settings"
        window.styleMask = [.titled, .closable, .resizable]
        window.setContentSize(NSSize(width: 400, height: 300))

        let windowController = NSWindowController(window: window)
        settingsWindowController = windowController

        centerWindow(window)
        windowController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func openAboutWindow() {
        if let windowController = aboutWindowController {
            windowController.showWindow(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let aboutView = AboutView()
        let hostingController = NSHostingController(rootView: aboutView)
        let window = NSWindow(
            contentViewController: hostingController
        )
        window.title = "About"
        window.styleMask = [.titled, .closable, .resizable]
        window.setContentSize(NSSize(width: 400, height: 300))

        let windowController = NSWindowController(window: window)
        aboutWindowController = windowController

        centerWindow(window)
        windowController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func centerWindow(_ window: NSWindow) {
        if let screen = window.screen {
            let screenFrame = screen.visibleFrame
            let windowSize = window.frame.size
            let x = screenFrame.origin.x + (screenFrame.size.width - windowSize.width) / 2
            let y = screenFrame.origin.y + (screenFrame.size.height - windowSize.height) / 2
            window.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

    func setupGlobalShortcuts() {
        KeyboardShortcuts.onKeyUp(for: .compress) {
            if let fileURL = self.taskHelper.getSelectedFileFromFinder() {
                let outputURL = self.taskHelper.getOutputDirectory(inputURL: fileURL, isCompress: true)
                self.taskHelper.compressToZip(input: fileURL, output: outputURL)
            }
        }

        KeyboardShortcuts.onKeyUp(for: .decompress) {
            if let fileURL = self.taskHelper.getSelectedFileFromFinder() {
                let outputURL = self.taskHelper.getOutputDirectory(inputURL: fileURL,isCompress: false)
                self.taskHelper.decompressFile(input: fileURL, output: outputURL)
            }
        }

        KeyboardShortcuts.onKeyUp(for: .openMain) {
            self.openMainWindow()
        }

        KeyboardShortcuts.onKeyUp(for: .openSetting) {
            self.openSettingsWindow()
        }
    }

    func toggleDockIconVisibility(show: Bool) {
        if show {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}
