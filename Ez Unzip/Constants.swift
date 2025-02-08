//
//  Constants.swift
//  Ez Unzip
//
//  Created by kkxx on 2024/11/28.
//

import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let compress = Self("ez-compress", default: .init(.z, modifiers: [.command, .option]))
    static let decompress = Self("ez-decompress", default: .init(.u, modifiers: [.command, .option]))
    static let openMain = Self("ez-open-main", default: .init(.m, modifiers: [.command, .option]))
    static let openSetting = Self("ez-open-setting", default: .init(.s, modifiers: [.command, .option]))
    static let quit = Self("ez-quit", default: .init(.q, modifiers: [.command]))
    static let openAbout = Self("ez-open-about", default: .init(.a, modifiers: [.command, .option]))
}

let compressionFormats = ["zip"]

let DefaultCompressionFormat = "DefaultCompressionFormat"

let SameUnZipFolder = "sameUnZipFolder"

let ShowDockIcon = "ShowDockIcon"

extension UserDefaults {
    public func saveDefaultCompressionFormat(value: String) {
        set(value, forKey: DefaultCompressionFormat)
    }

    public func getDefaultCompressionFormat() -> String {
        return string(forKey: DefaultCompressionFormat) ?? "zip"
    }

    public func saveSameUnZipFolder(value: Bool) {
        setValue(value, forKey: SameUnZipFolder)
    }

    public func isSameUnZipFolder() -> Bool {
        return bool(forKey: SameUnZipFolder)
    }

    public func saveShowDocIcon(value: Bool) {
        setValue(value, forKey: ShowDockIcon)
    }

    public func isShowDocIcon() -> Bool {
        return bool(forKey: ShowDockIcon)
    }
}
