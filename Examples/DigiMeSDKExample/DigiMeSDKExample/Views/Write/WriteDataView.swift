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
								if viewModel.writeCredentials != nil {
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
												self.viewModel.logError(message: "Error reading pdf file")
												return
											}
											url.stopAccessingSecurityScopedResource()
											switch fileType {
											case .pdf:
												viewModel.uploadPdf(data: data, fileName: url.lastPathComponent)
											default:
												viewModel.uploadJson(data: data, fileName: url.lastPathComponent)
											}
											
										case .failure(let error):
											self.viewModel.logError(message: "Error reading file: \(error)")
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
												viewModel.uploadImage(data: data, fileName: "identifier")
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
									viewModel.showContractDetails()
								} label: {
									HStack {
										Image("certIcon")
											.listRowIcon(color: .orange)
										Text("Request Contract Details")
									}
								}
							}
							
							Section("Read Uploaded Data") {
								if viewModel.readCredentials != nil {
									Button {
										viewModel.readData()
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
									viewModel.showContractDetails()
								} label: {
									HStack {
										Image("certIcon")
											.listRowIcon(color: .orange)
										Text("Request Contract Details")
									}
								}
							}
							
							if viewModel.writeCredentials != nil || viewModel.readCredentials != nil {
								Section("Delete Your Data") {
									Button {
										viewModel.deleteUser()
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
						if viewModel.isLoading {
							ActivityIndicator()
								.frame(width: 20, height: 20)
								.foregroundColor(.gray)
								.padding(.trailing, 10)
						}
						else {
							ShareLink(item: viewModel.logs.json)
						}
					}
		}, bottom: {
			LogOutputView(logs: $viewModel.logs)
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
