//
//  MemoryIntensiveClass.swift
//  DigiMeSDKExample
//
//  Created on 12/04/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

class MemoryIntensiveClass: ObservableObject {
    @Published var result = 0

    func allocateMemoryObjects(_ completion: (() -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            let numberOfBlobs = 100 // Number of data blobs to create
            var dataBlobs: [Data] = []

            for _ in 0..<numberOfBlobs {
                let blobSize = 1_000_000 // Size of each data blob
                let randomData = Data((0..<blobSize).map { _ in UInt8.random(in: 0...255) })
                dataBlobs.append(randomData)

                DispatchQueue.main.async {
                    self.result = dataBlobs.count
                }
            }

            completion?()
        }
    }
}
