//
//  ServiceObjectType.swift
//  DigiMeSDK
//
//  Created on 06/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

public struct ServiceObjectType: Encodable {
    public let identifier: UInt
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
    }
    
    public init(identifier: UInt) {
        self.identifier = identifier
    }
}
