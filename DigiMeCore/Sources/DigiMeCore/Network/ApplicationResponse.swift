//
//  ApplicationResponse.swift
//  DigiMeSDK
//
//  Created on 12/03/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

struct ApplicationResponse: Codable {
    let identifier: String
    let name: String
    let status: Int
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(String.self, forKey: .identifier)
        name = try container.decode(String.self, forKey: .name)
        status = try container.decode(Int.self, forKey: .status)
    }
}
