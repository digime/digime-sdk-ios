//
//  PayloadIdentifiable.swift
//  DigiMeSDK
//
//  Created on 25.09.20.
//

import Foundation

public protocol PayloadIdentifiable: Codable {
    var id: String { get }
    var identifier: String { get }
}
