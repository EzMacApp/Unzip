//
//  ContentView.swift
//  Ez Unzip
//
//  Created by kkxx on 2024/11/27.
//

import KeyboardShortcuts
import LaunchAtLogin
import SWCompression
import SwiftUI
import UnrarKit
import ZIPFoundation

struct ContentView: View {
    @State private var selectedFileURL: URL? = nil
    @State private var taskHelper = TaskHelper.shard
    @State private var isProcessing: Bool = false

    var body: some View {
        VStack {
            if isProcessing {
                ProgressView("Processing...")
                    .padding()
            } else {
                Text("Drag & Drop Files Here")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 2))
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                        handleFileDrop(providers: providers)
                    }
            }
        }
        .padding()
    }

    func handleFileDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
            if let data = item as? Data, let fileURL = URL(dataRepresentation: data, relativeTo: nil) {
                DispatchQueue.main.async {
                    selectedFileURL = fileURL
                    showSavePanelAndProcess(isCompress: false)
                }
            }
        }
        return true
    }

    func showSavePanelAndProcess(isCompress:Bool) {
        guard let inputURL = selectedFileURL else {
            _ = "No file selected"
            return
        }
        
        let outputURL = taskHelper.getOutputDirectory(inputURL: inputURL, isCompress: false)

        isProcessing = true
        DispatchQueue.global(qos: .userInitiated).async {
            taskHelper.decompressFile(input: inputURL, output: outputURL)
            DispatchQueue.main.async {
                isProcessing = false
            }
        }
    }
}

#Preview {
    ContentView()
}
