//
//  Service.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// A data source
public struct Service: Codable {
    
    /// The service's identifier
    let identifier: String
    
    /// The service's name
    let name: String
}
