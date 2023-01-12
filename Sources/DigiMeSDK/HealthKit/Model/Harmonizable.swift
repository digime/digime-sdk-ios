//
//  Harmonizable.swift
//  DigiMeSDK
//
//  Created on 25.09.20.
//

import Foundation

protocol Harmonizable {
    associatedtype Harmonized: Codable

    func harmonize() throws -> Harmonized
}
