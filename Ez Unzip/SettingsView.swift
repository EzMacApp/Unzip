//
//  SettingsView.swift
//  Ez Unzip
//
//  Created by kkxx on 2024/11/29.
//

import KeyboardShortcuts
import LaunchAtLogin
import SwiftUI

struct SettingsView: View {
    @State private var launchAtLoginEnabled = LaunchAtLogin.isEnabled
    @State private var defaultCompressionFormat = "zip"

    @State private var sameUnZipFolder = false
    @State private var showDockIcon = true

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center, spacing: 45) {
                Image(systemName: "command")
                    .resizable()
                    .frame(width: 24, height: 24)

                VStack {
                    HStack {
                        Image(systemName: "archivebox.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                        KeyboardShortcuts.Recorder(for: .decompress)
                    }

                    HStack {
                        Image(systemName: "archivebox.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                        KeyboardShortcuts.Recorder(for: .compress)
                    }

//                    HStack {
//                        Image(systemName: "macwindow")
//                            .resizable()
//                            .frame(width: 19, height: 19)
//                        KeyboardShortcuts.Recorder(for: .openMain)
//                    }

                    HStack {
                        Image(systemName: "gear")
                            .resizable()
                            .frame(width: 20, height: 20)
                        KeyboardShortcuts.Recorder(for: .openSetting)
                    }

                    HStack {
                        Image(systemName: "a.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                        KeyboardShortcuts.Recorder(for: .openAbout)
                    }
                }
            }
            Divider().padding(.vertical)

            HStack(alignment: .center, spacing: 45) {
                Image(systemName: "document")
                    .resizable()
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "archivebox.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Picker("", selection: $defaultCompressionFormat) {
                            ForEach(compressionFormats, id: \.self) { format in
                                Text(format.uppercased()).tag(format)
                            }
                        }
                        .pickerStyle(.segmented)
                    }.frame(width: 200)
                    HStack(alignment: .top) {
                        Image(systemName: sameUnZipFolder ? "folder.circle.fill" : "folder.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Toggle("", isOn: $sameUnZipFolder)
                            .onChange(of: sameUnZipFolder) { _ in
                                saveSettings()
                            }.toggleStyle(.checkbox)
                    }
                }
            }

            Divider().padding(.vertical)

            HStack(alignment: .center, spacing: 45) {
                Image(systemName: "gear")
                    .resizable()
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Image(systemName: launchAtLoginEnabled ? "power.circle.fill" : "power.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Toggle("", isOn: $launchAtLoginEnabled)
                            .onChange(of: launchAtLoginEnabled) { newValue in
                                LaunchAtLogin.isEnabled = newValue
                                saveSettings()
                            }.toggleStyle(.checkbox)
                    }

                    HStack(alignment: .top) {
                        Image(systemName: showDockIcon ? "eye.circle.fill" : "eye.slash.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Toggle("", isOn: $showDockIcon)
                            .onChange(of: showDockIcon) { newValue in
                                saveSettings()
                                toggleDockIconVisibility(show: newValue)
                            }
                            .toggleStyle(.checkbox)
                    }
                }
            }
        }
        .padding([.leading, .trailing], 30)

        .padding()
        .frame(width: 430, height: 400)
        .onAppear {
            loadSettings()
        }
        .onChange(of: defaultCompressionFormat) { _ in
            saveSettings()
        }
    }

    func saveSettings() {
        UserDefaults.standard.saveDefaultCompressionFormat(value: defaultCompressionFormat)
        UserDefaults.standard.saveSameUnZipFolder(value: sameUnZipFolder)
        UserDefaults.standard.saveShowDocIcon(value: showDockIcon)
    }

    func loadSettings() {
        defaultCompressionFormat = UserDefaults.standard.getDefaultCompressionFormat()
        sameUnZipFolder = UserDefaults.standard.isSameUnZipFolder()
        showDockIcon = UserDefaults.standard.isShowDocIcon()
        print("loadSettings: showDockIcon =  \(showDockIcon), sameUnZipFilder = \(sameUnZipFolder), defaultCompressionFormat = \(defaultCompressionFormat)")
    }

    func toggleDockIconVisibility(show: Bool) {
        if show {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}

#Preview {
    SettingsView()
}
