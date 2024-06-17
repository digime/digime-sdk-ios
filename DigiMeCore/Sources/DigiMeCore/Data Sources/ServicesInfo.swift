//
//  ServicesInfo.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Info for services and related groups
public struct ServicesInfo: Codable {
    public let countries: [SourceCountry]
    public let serviceGroups: [ServiceGroupType]
    public let services: [Service]
    
    public init(countries: [SourceCountry], serviceGroups: [ServiceGroupType], services: [Service]) {
        self.countries = countries
        self.serviceGroups = serviceGroups
        self.services = services
    }
}
