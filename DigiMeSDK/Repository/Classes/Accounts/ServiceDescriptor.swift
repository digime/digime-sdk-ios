//
//  ServiceDescriptor.swift
//  DigiMeSDK
//
//  Created on 21/09/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

@objcMembers
public class ServiceDescriptor: NSObject, Decodable {
    
    public var name: String
    
    public var logoUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case logoUrl = "logo"
    }
}
