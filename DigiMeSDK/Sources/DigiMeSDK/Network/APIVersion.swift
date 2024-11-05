//
//  APIVersion.swift
//  DigiMeSDK
//
//  Created on 05/11/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

enum APIVersion {
    case `public`
    case `internal`
    
    var value: String {
        switch self {
        case .public:
            return "/v1.7"
        case .internal:
            return "/v1.8"
        }
    }
}
