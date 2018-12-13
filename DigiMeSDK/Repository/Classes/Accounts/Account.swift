//
//  Account.swift
//  DigiMeRepository
//
//  Created on 21/09/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

@objcMembers
public class Account: NSObject, Decodable {
    
    public var identifier: String
    
    public var name: String
    
    public var number: String?
    
    public var service: ServiceDescriptor
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case number
        case service
    }
}
