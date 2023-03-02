//
//  DataCompressor.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation
import Gzip

enum DataCompressor {
    case gzip
    
    func decompress(data: Data) throws -> Data {
        switch self {
        case .gzip:
//            return try data.gunzipped()
			return try (data as NSData).decompressed(using: .lzma) as Data
        }
    }
}
