//
//  SourceImage.swift
//  DigiMeSDKExample
//
//  Created on 24/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Combine
import SwiftUI

class ImageLoader: ObservableObject {
    @Published var image: Image?
    private var cancellables = Set<AnyCancellable>()
    private static let cache = NSCache<NSURL, UIImage>()

    func load(fromURL url: URL) {
        if let cachedImage = ImageLoader.cache.object(forKey: url as NSURL) {
            self.image = Image(uiImage: cachedImage)
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure = completion {
                    self.image = Image(systemName: "wifi.slash")
                }
            } receiveValue: { [weak self] fetchedImage in
                if let fetchedImage = fetchedImage {
                    ImageLoader.cache.setObject(fetchedImage, forKey: url as NSURL)
                    self?.image = Image(uiImage: fetchedImage)
                }
            }
            .store(in: &cancellables)
    }
}

struct SourceImage: View {
    @StateObject private var loader = ImageLoader()
    let url: URL

    var body: some View {
        Group {
            if let image = loader.image {
                image
                    .resizable()
                    .transition(.scale(scale: 0.1, anchor: .center))
            }
            else {
                ProgressView()
                    .frame(width: 10, height: 10)
            }
        }
        .onAppear {
            loader.load(fromURL: url)
        }
        .frame(width: 20, height: 20)
        .clipShape(Circle())
    }
}
