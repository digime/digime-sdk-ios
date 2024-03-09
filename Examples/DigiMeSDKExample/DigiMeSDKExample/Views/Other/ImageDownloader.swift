//
//  ImageDownloader.swift
//  DigiMeSDKExample
//
//  Created on 25/02/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Combine
import CryptoKit
import Foundation
import SwiftUI

class ImageDownloader: ObservableObject {
    enum DownloadState {
        case notStarted
        case inProgress(Double) // Progress as a fraction
        case completed(URL)     // Local file URL
        case failed
    }

    @Published var downloadState: DownloadState = .notStarted
    private var cancellables = Set<AnyCancellable>()

    func download(fromURL url: URL, to localURL: URL) {
        // Check if the file already exists at the local URL
        if FileManager.default.fileExists(atPath: localURL.path) {
            // If file exists, immediately move to the completed state
            DispatchQueue.main.async {
                self.downloadState = .completed(localURL)
            }
            return
        }

        downloadState = .inProgress(0)

        let request = URLRequest(url: url)
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .tryMap { data -> URL in
                try data.write(to: localURL, options: .atomic)
                return localURL
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.downloadState = .completed(localURL)
                case .failure:
                    self?.downloadState = .failed
                }
            } receiveValue: { [weak self] _ in
                self?.downloadState = .completed(localURL)
            }
            .store(in: &cancellables)
    }
}

struct ImageDownloaderView: View {
    @StateObject private var downloader = ImageDownloader()

    let url: URL
    let localFileURL: URL
    let size: CGSize

    init(url: URL, size: CGSize) {
        self.url = url
        let inputData = Data(url.absoluteString.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashedFilename = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        self.localFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(hashedFilename).svg")
        self.size = size
    }

    var body: some View {
        Group {
            switch downloader.downloadState {
            case .notStarted, .inProgress:
                ProgressView()
                    .frame(width: size.width, height: size.height)
            case .completed(let fileURL):
                SVGWebView(url: fileURL)
                    .frame(width: size.width, height: size.height)
            case .failed:
                Image(systemName: "wifi.slash")
                    .frame(width: size.width, height: size.height)
            }
        }
        .frame(width: size.width, height: size.height)
        .onAppear {
            downloader.download(fromURL: url, to: localFileURL)
        }
    }
}

struct SVGDownloaderViewPreview: View {
    var body: some View {
        let url = URL(string: "https://securedownloads.digi.me/static/development/discovery/services/nhs/icon.svg")!
        ZStack {
            Color.blue

            ImageDownloaderView(url: url, size: CGSize(width: 50, height: 50))
        }
    }
}

#Preview {
    SVGDownloaderViewPreview()
}
