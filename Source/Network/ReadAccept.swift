//
//  ReadAccept.swift
//  DigiMeSDK
//
//  Created on 04/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

enum ReadAccept: Encodable {
    case gzipCompression
    
    enum CodingKeys: String, CodingKey {
        case compression
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .gzipCompression:
            try container.encode("gzip", forKey: .compression)
        }
    }
}
