//
//  WriteDataView.swift
//  DigiMeSDKExample
//
//  Created on 16/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import PhotosUI
import SwiftUI

struct WriteDataView: View {
	@ObservedObject private var viewModel = WriteDataViewModel()
	@State private var selectedPhoto: PhotosPickerItem?
	@State private var presentImporter = false
	@State private var fileType: UTType = .json
	
	var body: some View {
		SplitView(top: {
					VStack {
						List {
							Section("Upload Example Data") {
								if viewModel.credentialsForWrite != nil {
									Button {
										presentImporter = true
										fileType = .json
									} label: {
										HStack {
											Image("jsonIcon")
												.listRowIcon(color: .gray)
											Text("Upload JSON")
										}
									}
									
									Button {
										presentImporter = true
										fileType = .pdf
									} label: {
										HStack {
											Image("pdfIcon")
												.listRowIcon(color: .red)
											Text("Upload PDF")
										}
									}
									.fileImporter(isPresented: $presentImporter, allowedContentTypes: [fileType]) { result in
										switch result {
										case .success(let url):
											guard
												url.startAccessingSecurityScopedResource(),
												let data = try? Data(contentsOf: url) else {
												self.viewModel.logErrorMessage("Error reading pdf file")
												return
											}
											url.stopAccessingSecurityScopedResource()
											switch fileType {
											case .pdf:
												viewModel.submitPdfData(data: data, fileName: url.lastPathComponent)
											default:
												viewModel.submitJsonData(data: data, fileName: url.lastPathComponent)
											}
											
										case .failure(let error):
											self.viewModel.logErrorMessage("Error reading file: \(error)")
										}
									}
									
									PhotosPicker(selection: $selectedPhoto, matching: .images) {
										HStack {
											Image("imageIcon")
												.listRowIcon()
											Text("Upload Image")
										}
									}
									.onChange(of: selectedPhoto) { newItem in
										Task {
											if
												let data = try? await newItem?.loadTransferable(type: Data.self) {
												viewModel.submitImageData(data: data, fileName: "identifier")
											}
										}
									}
								}
								else {
									Button {
										viewModel.authorizeWriteContract()
									} label: {
										HStack {
											Image("passIcon")
												.listRowIcon(color: .green)
											Text("Authorise")
										}
									}
								}
								
								Button {
									viewModel.displayContractDetails()
								} label: {
									HStack {
										Image("certIcon")
											.listRowIcon(color: .orange)
										Text("Request Contract Details")
									}
								}
							}
							
							Section("Read Uploaded Data") {
								if viewModel.credentialsForRead != nil {
									Button {
										viewModel.retrieveData()
									} label: {
										HStack {
											Image(systemName: "arrow.down.doc")
												.foregroundColor(.green)
											Text("Read Data")
										}
									}
								}
								else {
									Button {
										viewModel.authorizeReadContract()
									} label: {
										HStack {
											Image("passIcon")
												.listRowIcon(color: .green)
											Text("Authorise")
										}
									}
								}
								
								Button {
									viewModel.displayContractDetails()
								} label: {
									HStack {
										Image("certIcon")
											.listRowIcon(color: .orange)
										Text("Request Contract Details")
									}
								}
							}
							
							if viewModel.credentialsForWrite != nil || viewModel.credentialsForRead != nil {
								Section("Delete Your Data") {
									Button {
										viewModel.removeUser()
									} label: {
										HStack {
											Image("deleteIcon")
												.listRowIcon(color: .red)
											Text("Start Over")
												.foregroundColor(.red)
										}
									}
								}
							}
						}
					}
					.navigationBarTitle("Write", displayMode: .inline)
					.toolbar {
						if viewModel.loadingInProgress {
							ActivityIndicator()
								.frame(width: 20, height: 20)
								.foregroundColor(.gray)
								.padding(.trailing, 10)
						}
						else {
							ShareLink(item: viewModel.logEntries.json)
						}
					}
		}, bottom: {
			LogOutputView(logs: $viewModel.logEntries)
		})
	}
}

struct WriteDataView_Previews: PreviewProvider {
    static var previews: some View {
		NavigationView {
			WriteDataView()
		}
    }
}
