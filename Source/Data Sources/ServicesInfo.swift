//
//  ServicesInfo.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Info for services and related groups
public struct ServicesInfo: Decodable {
    public let countries: [ServiceCountry]
    public let serviceGroups: [ServiceGroup]
    public let services: [Service]
}
