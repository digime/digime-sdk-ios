//
//  CAFileMetadata.swift
//  DigiMeSDK
//
//  Created on 23/05/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

import Foundation

@objcMembers
public class CAFileMetadata: NSObject, Decodable {

    var mimeType: CAMimeType
    var reference: [String]
    var tags: [String]
    var contractId: String
    
    enum CodingKeys: String, CodingKey {
        case mimeType = "mimetype"
        case reference
        case tags
        case contractId = "contractid"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.reference = try container.decode([String].self, forKey: .reference)
        self.contractId = try container.decode(String.self, forKey: .contractId)
        self.tags = try container.decode([String].self, forKey: .tags)
        
        let mimeString = try container.decode(String.self, forKey: .mimeType)
        self.mimeType = CAMimeType(stringLiteral: mimeString)
    }
    
    @objc(metadataFromJSON:)
    public static func metadata(from jsonDict: [AnyHashable: Any]) -> CAFileMetadata? {
        do {
            let encodedJSON = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
            return try JSONDecoder().decode(CAFileMetadata.self, from: encodedJSON)
        }
        catch {
            return nil
        }
    }
}
