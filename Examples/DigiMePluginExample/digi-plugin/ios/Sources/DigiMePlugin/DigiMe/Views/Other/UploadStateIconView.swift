//
//  UploadStateIconView.swift
//  DigiMeSDKExample
//
//  Created on 22/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import SwiftUI

struct UploadStateIconView: View {
    var uploadState: UploadState

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            switch uploadState {
            case .idle:
                Image(systemName: "icloud.and.arrow.up")
                    .font(.title3)
                    .foregroundColor(.gray)
            case .uploading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            case .uploaded:
                Image(systemName: "checkmark.icloud")
                    .font(.title3)
                    .foregroundColor(.accentColor)
            case .error:
                Image(systemName: "xmark.icloud")
                    .font(.title3)
                    .foregroundColor(.red)
//            case .paused:
//                Image(systemName: "pause.circle")
//                    .font(.title3)
//                    .foregroundColor(.red)
//            case .canceled:
//                Image(systemName: "trash")
//                    .font(.title3)
//                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    VStack(alignment: .center, spacing: 20) {
        UploadStateIconView(uploadState: .idle)
        UploadStateIconView(uploadState: .uploading)
        UploadStateIconView(uploadState: .uploaded)
        UploadStateIconView(uploadState: .error)
//        UploadStateIconView(uploadState: .paused)
//        UploadStateIconView(uploadState: .canceled)
    }
}
