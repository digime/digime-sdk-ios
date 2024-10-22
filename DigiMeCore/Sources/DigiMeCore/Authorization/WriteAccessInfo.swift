//
//  WriteAccessInfo.swift
//  DigiMeCore
//
//  Created on 11/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

public struct WriteAccessInfo: Codable {
    public let postboxId: String
    public let publicKey: String
    
    public init(postboxId: String, publicKey: String) {
        self.postboxId = postboxId
        self.publicKey = publicKey
    }
}
