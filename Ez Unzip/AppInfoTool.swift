//
//  AppInfoTool.swift
//  Ez Unzip
//
//  Created by kkxx on 2024/12/5.
//

import Foundation

func appVersion(in bundle: Bundle = .main) -> String {
    guard let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
        fatalError("CFBundleShortVersionString should not be missing from info dictionary")
    }
    return version
}

func appIcon(in bundle: Bundle = .main) -> String {
    guard let icons = bundle.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
          let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
          let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
          let iconFileName = iconFiles.last else {
        fatalError("Could not find icons in bundle")
    }
    return iconFileName
}

let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
