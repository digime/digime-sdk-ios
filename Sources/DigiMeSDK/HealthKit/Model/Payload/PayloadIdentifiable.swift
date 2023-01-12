//
//  PayloadIdentifiable.swift
//  DigiMeSDK
//
//  Created on 25.09.20.
//

import Foundation

protocol PayloadIdentifiable: Codable {
    var identifier: String { get }
}
