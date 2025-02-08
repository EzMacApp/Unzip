//
//  Helper.swift
//  Ez Unzip
//
//  Created by kkxx on 2024/12/1.
//

import SWCompression
import SwiftUI
import UnrarKit
import ZIPFoundation

public enum TaskState {
    case Doing, Done(String), Error(String), Idle
}

class TaskHelper: ObservableObject {
    @Published var taskState = TaskState.Idle

    static let shard = TaskHelper()

    // MARK: - Compress

    func compressToZip(input: URL, output: URL) {
        let zipFormat = UserDefaults.standard.getDefaultCompressionFormat()
        do {
            let zipFileName = input.lastPathComponent + ".\(zipFormat)"
            let zipFileURL = output /* resolveUniqueURL(output.appendingPathComponent(zipFileName))*/
            try FileManager.default.zipItem(at: input, to: zipFileURL)
            taskState = TaskState.Done("Compressed to \(zipFileURL.path)")
        } catch {
            taskState = TaskState.Error("Compression failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Decompress

    func decompressFile(input: URL, output: URL) {
        let fileExtension = input.pathExtension.lowercased()

        switch fileExtension {
        case "zip":
            decompressZipFile(input: input, output: output)
        case "gz", "bz2", "xz", "tar":
            decompressWithSWCompression(input: input, output: output)
        case "rar":
            decompressRarFile(input: input, output: output)
        default:
            taskState = TaskState.Error("Unsupported file format: \(fileExtension)")
            return
        }

        deleteMacOSXFiles(in: output)
        var parentUrl = output.appendingPathComponent(input.deletingPathExtension().lastPathComponent, isDirectory: true)
        print("parentUrl = \(parentUrl)")

//        recursivelyDecompressFiles(in: parentUrl)
    }

    func decompressZipFile(input: URL, output: URL) {
        do {
            let fileManager = FileManager.default
            let destinationFolder = output
            // 创建一个临时目录用于解压
            let tempDirectoryURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try fileManager.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true, attributes: nil)

            // 先解压到临时目录
            try fileManager.unzipItem(at: input, to: tempDirectoryURL, pathEncoding: .utf8)

            // 获取解压后的文件列表
            let extractedItems = try fileManager.contentsOfDirectory(at: tempDirectoryURL, includingPropertiesForKeys: nil)

            try FileManager.default.createDirectory(at: destinationFolder, withIntermediateDirectories: true)
            // 移动文件到目标目录
            if extractedItems.count == 1, let firstItem = extractedItems.first, fileManager.isDirectory(at: firstItem) {
                let folderContents = try fileManager.contentsOfDirectory(at: firstItem, includingPropertiesForKeys: nil)
                for item in folderContents {
                    let destinationItemURL = destinationFolder.appendingPathComponent(item.lastPathComponent)
                    try fileManager.moveItem(at: item, to: destinationItemURL)
                }
            } else {
                for item in extractedItems {
                    let destinationItemURL = destinationFolder.appendingPathComponent(item.lastPathComponent)
                    try fileManager.moveItem(at: item, to: destinationItemURL)
                }
            }

            // 删除临时目录
            try fileManager.removeItem(at: tempDirectoryURL)

            taskState = TaskState.Done("Decompressed ZIP to \(destinationFolder.path)")
        } catch {
            taskState = TaskState.Error("Decompression failed: \(error.localizedDescription)")
        }
        print("TaskState >>> \(taskState)")
    }

    func decompressRarFile(input: URL, output: URL) {
        do {
            let archive = try URKArchive(url: input)
//            var temp = input.deletingPathExtension().lastPathComponent
            let destinationFolder = output
            try FileManager.default.createDirectory(at: destinationFolder, withIntermediateDirectories: true)
            try archive.extractFiles(to: destinationFolder.path, overwrite: true)
            taskState = TaskState.Done("Successfully decompressed RAR to \(destinationFolder.path)")
        } catch {
            taskState = TaskState.Error("Decompression failed: \(error.localizedDescription)")
        }
        print("TaskState >>> \(taskState)")
    }

    func decompressWithSWCompression(input: URL, output: URL) {
        do {
            let destinationFolder = output.appendingPathComponent(input.deletingPathExtension().lastPathComponent)
            try FileManager.default.createDirectory(at: destinationFolder, withIntermediateDirectories: true)

            let data = try Data(contentsOf: input)

            switch input.pathExtension {
            case "gz":
                let decompressedData = try GzipArchive.unarchive(archive: data)
                let outputFile = destinationFolder.appendingPathComponent(input.deletingPathExtension().lastPathComponent)
                try decompressedData.write(to: outputFile)
            case "bz2":
                let decompressedData = try BZip2.decompress(data: data)
                let outputFile = destinationFolder.appendingPathComponent(input.deletingPathExtension().lastPathComponent)
                try decompressedData.write(to: outputFile)
            case "xz":
                let decompressedData = try XZArchive.unarchive(archive: data)
                let outputFile = destinationFolder.appendingPathComponent(input.deletingPathExtension().lastPathComponent)
                try decompressedData.write(to: outputFile)
            case "tar":
                let entries = try TarContainer.open(container: data)
                for entry in entries {
                    if let entryData = entry.data {
                        let filePath = destinationFolder.appendingPathComponent(entry.info.name)
                        try entryData.write(to: filePath)
                    }
                }
            default:
                throw NSError(domain: "UnsupportedFormat", code: 0, userInfo: nil)
            }

            taskState = TaskState.Done("Decompressed \(input.pathExtension) to \(destinationFolder.path)")
        } catch {
            taskState = TaskState.Error("Decompression failed: \(error.localizedDescription)")
        }
    }

    func recursivelyDecompressFiles(in directory: URL) {
        print("recursively Decompress for \(directory)")
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)

            for file in contents {
                let fileExtension = file.pathExtension.lowercased()

                if ["zip", "gz", "bz2", "xz", "tar", "rar"].contains(fileExtension) {
                    decompressFile(input: file, output: directory)
                }
            }
        } catch {
            taskState = TaskState.Error("Failed to process directory \(directory.path): \(error.localizedDescription)")
        }
    }

    func isDirectory(url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    // MARK: - utils

    public func getOutputDirectory(inputURL: URL, isCompress: Bool) -> URL {
        var outputURL: URL
        if UserDefaults.standard.isSameUnZipFolder() {
            outputURL = inputURL.deletingPathExtension()
            outputURL = resolveUniqueURL(outputURL, isCompress)
        } else {
            let panel = NSOpenPanel()
            panel.canChooseFiles = false
            panel.canChooseDirectories = true
            panel.allowsMultipleSelection = false
            panel.prompt = "Select Output Directory"

            if panel.runModal() == .OK {
                outputURL = panel.url ?? inputURL.deletingLastPathComponent()
            } else {
                outputURL = inputURL.deletingLastPathComponent()
            }
        }
        return outputURL
    }

    func resolveLastDecompressionFolder(output: URL, input: URL) -> URL? {
        let lastPathComponent = input.deletingPathExtension().lastPathComponent
        let potentialFolder = output.appendingPathComponent(lastPathComponent)

        if FileManager.default.fileExists(atPath: potentialFolder.path) {
            return potentialFolder
        }

        return nil
    }

    func resolveUniqueURL(_ url: URL, _ isCompress: Bool) -> URL {
        var uniqueURL = url
        let zipFormat = UserDefaults.standard.getDefaultCompressionFormat()
        let zipFileName = "\(zipFormat)"
        if isCompress {
            let last = uniqueURL.lastPathComponent
            uniqueURL.deleteLastPathComponent()
            uniqueURL = uniqueURL.appendingPathComponent(last, isDirectory: false)
            uniqueURL = uniqueURL.appendingPathExtension(zipFileName)
        }
        var counter = 1

        while FileManager.default.fileExists(atPath: uniqueURL.path) {
            let fileExtension = url.pathExtension
            let baseName = url.deletingPathExtension().lastPathComponent
            let newName = "\(baseName)(\(counter))"
            uniqueURL = url.deletingLastPathComponent().appendingPathComponent(newName).appendingPathExtension(fileExtension)
            uniqueURL = uniqueURL.appendingPathExtension(zipFileName)
            counter += 1
        }

        return uniqueURL
    }

    func getSelectedFileFromFinder() -> URL? {
        var selectedFileURL: URL?
        let script = """
        tell application "System Events"
            if not (exists process "Finder") then
                tell application "Finder" to launch
            end if
        end tell
        delay 0.2
        tell application "Finder"
            set theSelection to selection as alias list
            if theSelection is not {} then
                set theFile to item 1 of theSelection
                POSIX path of theFile
            else
                ""
            end if
        end tell
        """

        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            if let output = scriptObject.executeAndReturnError(&error).stringValue {
                selectedFileURL = URL(fileURLWithPath: output)
            }
        }
        return selectedFileURL
    }

    func deleteMacOSXFiles(in directory: URL) {
        let fileManager = FileManager.default

        do {
            let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)

            for item in contents {
                if item.lastPathComponent == "__MACOSX" {
                    do {
                        try fileManager.removeItem(at: item)
                        print("Deleted: \(item.path)")
                    } catch {
                        print("Failed to delete: \(item.path). Error: \(error.localizedDescription)")
                    }
                } else {
                    var isDirectory: ObjCBool = false
                    if fileManager.fileExists(atPath: item.path, isDirectory: &isDirectory), isDirectory.boolValue {
                        deleteMacOSXFiles(in: item)
                    }
                }
            }
        } catch {
            print("Failed to read contents of \(directory.path). Error: \(error.localizedDescription)")
        }
    }
}

// 辅助方法：检查文件是否是目录
extension FileManager {
    func isDirectory(at url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        fileExists(atPath: url.path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
}
