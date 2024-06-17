//
//  HealthDataStorageFileListView.swift
//  DigiMeSDKExample
//
//  Created on 02/06/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import SwiftUI

struct HealthDataStorageFileListView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var fileList: [StorageFileInfo]

    var body: some View {
        NavigationView {
            List(fileList, id: \.id) { file in
                VStack(alignment: .leading) {
                    Text(file.originalName)
                        .font(.headline)
                    Text(file.path)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = file.originalName
                    }, label: {
                        Text("Copy File Name")
                    })
                }
            }
            .navigationBarTitle("Files", displayMode: .inline)
            .navigationBarItems(leading: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    HealthDataStorageFileListView(fileList: [])
}
