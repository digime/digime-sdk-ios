//
//  DocumentPicker.swift
//  DigiMeSDKExample
//
//  Created on 02/06/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct DocumentPicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                return
            }
            
            parent.viewModel.handleFileSelection(url: url)
        }
    }

    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: FileViewModel

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}

struct DocumentPickerPreview: View {
    @StateObject private var viewModel = FileViewModel()
    @State private var isFilePickerPresented = false

    var body: some View {
        VStack {
            if let fileName = viewModel.fileName {
                Text("Selected File: \(fileName)")
            } 
            else {
                Text("No file selected")
            }

            Button("Select File") {
                isFilePickerPresented = true
            }
            .sheet(isPresented: $isFilePickerPresented) {
                DocumentPicker(viewModel: viewModel)
            }
        }
        .padding()
    }
}

#Preview {
    DocumentPickerPreview()
}

