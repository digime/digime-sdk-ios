//
//  ContractResponse.swift
//  DigiMeSDK
//
//  Created on 12/03/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

public struct ContractResponse: Codable {
    let accessType: String // r|w
    let application: ApplicationResponse
    let certificate: String
    let certificateContractSchemaVersion: String
    let expirationDate: Date
    let identifier: String
    let partnerId: String
    let type: String // x509|json
    
    enum CodingKeys: String, CodingKey {
        case accessType
        case application
        case certificate
        case certificateContractSchemaVersion
        case expirationDate
        case identifier = "id"
        case partnerId
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessType = try container.decode(String.self, forKey: .accessType)
        application = try container.decode(ApplicationResponse.self, forKey: .application)
        certificate = try container.decode(String.self, forKey: .certificate)
        certificateContractSchemaVersion = try container.decode(String.self, forKey: .certificateContractSchemaVersion)
        expirationDate = try container.decode(Date.self, forKey: .expirationDate)
        identifier = try container.decode(String.self, forKey: .identifier)
        partnerId = try container.decode(String.self, forKey: .partnerId)
        type = try container.decode(String.self, forKey: .type)
    }
}
