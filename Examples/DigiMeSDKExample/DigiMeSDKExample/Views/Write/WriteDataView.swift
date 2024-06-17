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
    @EnvironmentObject private var viewModel: WriteDataViewModel

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var presentImporter = false
    @State private var presentPhotoPicker = false
    @State private var fileType: UTType = .json
    @Binding var navigationPath: NavigationPath

    var body: some View {
        SplitView(top: {
            VStack {
                ScrollView {
                    SectionView(header: "Upload Example Data") {
                        if viewModel.credentialsForWrite != nil {
                            StyledPressableButtonView(text: "Upload JSON",
                                                      iconName: "jsonIcon",
                                                      iconForegroundColor: viewModel.loadingInProgress ? .gray : .green,
                                                      textForegroundColor: viewModel.loadingInProgress ? .gray : .accentColor,
                                                      backgroundColor: Color(.secondarySystemGroupedBackground)) {
                                presentImporter = true
                                fileType = .json
                            }
                                                      .disabled(viewModel.loadingInProgress)

                            StyledPressableButtonView(text: "Upload PDF",
                                                      iconName: "pdfIcon",
                                                      iconForegroundColor: viewModel.loadingInProgress ? .gray : .red,
                                                      textForegroundColor: viewModel.loadingInProgress ? .gray : .accentColor,
                                                      backgroundColor: Color(.secondarySystemGroupedBackground)) {
                                presentImporter = true
                                fileType = .pdf
                            }
                                                      .disabled(viewModel.loadingInProgress)

                            StyledPressableButtonView(text: "Upload Image",
                                                      iconSystemName: "photo.on.rectangle.angled",
                                                      iconForegroundColor: .gray,
                                                      textForegroundColor: viewModel.loadingInProgress ? .gray : .accentColor,
                                                      backgroundColor: Color(.secondarySystemGroupedBackground)) {
                                presentPhotoPicker = true
                                fileType = .image
                            }
                                                      .disabled(viewModel.loadingInProgress)
                        }
                        else {
                            StyledPressableButtonView(text: "Authorise",
                                                      iconName: "passIcon",
                                                      iconForegroundColor: viewModel.loadingInProgress ? .gray : .green,
                                                      textForegroundColor: viewModel.loadingInProgress ? .gray : .accentColor,
                                                      backgroundColor: Color(.secondarySystemGroupedBackground)) {
                                viewModel.authorizeWriteContract()
                            }
                                                      .disabled(viewModel.loadingInProgress)
                        }

                        StyledPressableButtonView(text: "Request Contract Details",
                                                  iconName: "certIcon",
                                                  iconForegroundColor: viewModel.loadingInProgress ? .gray : .orange,
                                                  textForegroundColor: viewModel.loadingInProgress ? .gray : .accentColor,
                                                  backgroundColor: Color(.secondarySystemGroupedBackground)) {
                            viewModel.authorizeWriteContract()
                        }
                                                  .disabled(viewModel.loadingInProgress)
                    }

                    SectionView(header: "Read Uploaded Data") {
                        if viewModel.credentialsForRead != nil {
                            StyledPressableButtonView(text: "Read Data",
                                                      iconSystemName: "arrow.down.doc",
                                                      iconForegroundColor: viewModel.loadingInProgress ? .gray : .green,
                                                      textForegroundColor: viewModel.loadingInProgress ? .gray : .accentColor,
                                                      backgroundColor: Color(.secondarySystemGroupedBackground)) {
                                viewModel.retrieveData()
                            }
                                                      .disabled(viewModel.loadingInProgress)
                        }
                        else {
                            StyledPressableButtonView(text: "Authorise",
                                                      iconName: "passIcon",
                                                      iconForegroundColor: viewModel.loadingInProgress ? .gray : .green,
                                                      textForegroundColor: viewModel.loadingInProgress ? .gray : .accentColor,
                                                      backgroundColor: Color(.secondarySystemGroupedBackground)) {
                                viewModel.authorizeReadContract()
                            }
                                                      .disabled(viewModel.loadingInProgress)
                        }

                        StyledPressableButtonView(text: "Request Contract Details",
                                                  iconName: "certIcon",
                                                  iconForegroundColor: viewModel.loadingInProgress ? .gray : .orange,
                                                  textForegroundColor: viewModel.loadingInProgress ? .gray : .accentColor,
                                                  backgroundColor: Color(.secondarySystemGroupedBackground)) {
                            viewModel.displayContractDetails()
                        }
                                                  .disabled(viewModel.loadingInProgress)
                    }

                    if viewModel.credentialsForWrite != nil || viewModel.credentialsForRead != nil {
                        SectionView(header: "Delete Your Data") {
                            
                            StyledPressableButtonView(text: "Delete Data and Clear Logs",
                                                      iconName: "deleteIcon",
                                                      iconForegroundColor: viewModel.loadingInProgress ? .gray : .red,
                                                      textForegroundColor: viewModel.loadingInProgress ? .gray : .red,
                                                      backgroundColor: Color(.secondarySystemGroupedBackground)) {
                                viewModel.reset()
                            }
                                                      .disabled(viewModel.loadingInProgress)
                        }
                    }
                }

                if presentPhotoPicker {
                    PhotosPicker("Select images", selection: $selectedPhoto, matching: .images)
                }
            }
            .navigationBarTitle("Write", displayMode: .inline)
            .background(Color(.systemGroupedBackground))
            .photosPicker(isPresented: $presentPhotoPicker, selection: $selectedPhoto, matching: .images, photoLibrary: .shared())
            .toolbar {
                if viewModel.loadingInProgress {
                    ActivityIndicator()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.gray)
                        .padding(.trailing, 10)
                }
                else {
                    ShareLink(item: viewModel.exportLogs())
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
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if
                        let data = try? await newItem?.loadTransferable(type: Data.self) {
                        viewModel.submitImageData(data: data, fileName: "identifier")
                    }
                }
            }
        }, bottom: {
            LogOutputView()
        })
    }
}

#Preview {
    do {
        let previewer = try Previewer()

        return NavigationView {
            WriteDataView(navigationPath: .constant(NavigationPath()))
                .environmentObject(WriteDataViewModel(modelContext: previewer.container.mainContext))
                .modelContainer(previewer.container)
                .environment(\.colorScheme, .dark)
        }
    }
    catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
