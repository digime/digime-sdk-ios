//
//  SVGDownloader.swift
//  DigiMeSDKExample
//
//  Created on 09/03/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

class SVGDownloader: ObservableObject {
    @Published var downloadState: DownloadState = .notStarted

    enum DownloadState {
        case notStarted
        case inProgress
        case completed(Data)
        case failed(Error?)
    }

    func downloadSVG(from url: URL) {
        // Check if the URL is already cached
        if let cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url)) {
            DispatchQueue.main.async {
                self.downloadState = .completed(cachedResponse.data)
            }
            return
        }

        self.downloadState = .inProgress

        // No cached data, fetch from the network
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.downloadState = .failed(error)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                    self.downloadState = .failed(nil)
                    return
                }

                // Cache the downloaded data
                if let response = response {
                    let cachedData = CachedURLResponse(response: response, data: data)
                    URLCache.shared.storeCachedResponse(cachedData, for: URLRequest(url: url))
                }

                self.downloadState = .completed(data)
            }
        }
        task.resume()
    }
}

struct SVGImageView: View {
    @StateObject var downloader = SVGDownloader()
    let url: URL
    let size: CGSize

    var body: some View {
        Group {
            switch downloader.downloadState {
            case .notStarted, .inProgress:
                ProgressView()
            case .completed(_):
                SVGWebView(url: url)
                    .frame(width: size.width, height: size.height)
            case .failed:
                Image(systemName: "wifi.slash")
            }
        }
        .onAppear {
            downloader.downloadSVG(from: url)
        }
    }
}
