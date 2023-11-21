//
//  AccountServiceDescriptor.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Short description of a service relating to user's account
public struct AccountServiceDescriptor: Codable {
    
    /// The name of the service.  This matches the name of a service in the response to `DigiMe.availableServices(completion:)`
    public let name: String
    
    /// The logo for the service, if available
    public let logo: String?
    
    public init(name: String, logo: String? = nil) {
        self.name = name
        self.logo = logo
    }
}
