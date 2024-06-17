//
//  FileViewModel.swift
//  DigiMeSDKExample
//
//  Created on 02/06/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import SwiftUI

class FileViewModel: ObservableObject {
    @Published var fileData: Data? = nil
    @Published var fileName: String? = nil

    func handleFileSelection(url: URL) {
        // Start accessing a security-scoped resource.
        guard url.startAccessingSecurityScopedResource() else {
            print("Couldn't access the security-scoped resource.")
            return
        }

        defer {
            // Always stop accessing the resource when done.
            url.stopAccessingSecurityScopedResource()
        }
        
        do {
            let data = try Data(contentsOf: url)
            DispatchQueue.main.async {
                self.fileData = data
                self.fileName = url.lastPathComponent
            }
        } catch {
            print("Error reading file: \(error.localizedDescription)")
        }
    }
}

struct FileImporterPreview: View {
    @StateObject private var viewModel = FileViewModel()
    @State private var isFilePickerPresented = false

    var body: some View {
        VStack {
            if let fileName = viewModel.fileName {
                Text("Selected File: \(fileName)")
            } else {
                Text("No file selected")
            }

            Button("Select File") {
                isFilePickerPresented = true
            }
            .fileImporter(
                isPresented: $isFilePickerPresented,
                allowedContentTypes: [.item],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        viewModel.handleFileSelection(url: url)
                    }
                case .failure(let error):
                    print("Error selecting file: \(error.localizedDescription)")
                }
            }
        }
        .padding()
    }
}

#Preview {
    FileImporterPreview()
}

