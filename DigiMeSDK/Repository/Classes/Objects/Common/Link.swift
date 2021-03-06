//
//  Link.swift
//  DigiMeSDK
//
//  Created on 25/09/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

@objcMembers
public class Link: NSObject, Decodable {
    public let link: String?
    public let resources: [MediaResource]?
    public let subtitle: String?
    public let title: String?
    
    enum CodingKeys: String, CodingKey {
        case link = "link"
        case resources = "resources"
        case subtitle = "subtitle"
        case title = "title"
    }
}
