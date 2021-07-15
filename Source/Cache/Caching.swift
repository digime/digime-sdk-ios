//
//  Caching.swift
//  DigiMeSDK
//
//  Created on 15/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

protocol Caching {
    associatedtype ContentType
    
    var contents: ContentType? { get set }
    var lastUpdate: Date { get }
}
