//
//  ConnectionSecurity.swift
//  DigiMeCore
//
//  Created on 13/04/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Foundation

@objcMembers
public class ConnectionSecurity: NSObject, Codable {
    public var password: ConnectionSecurityConfigurations?
}

@objcMembers
public class ConnectionSecurityConfigurations: NSObject, Codable {
    public var requireAfter: String?
    public var required: Bool?
}
