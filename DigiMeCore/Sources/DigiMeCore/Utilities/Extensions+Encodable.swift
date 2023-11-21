//
//  Extensions+Encodable.swift
//  DigiMeSDK
//
//  Created on 01.10.20.
//

import Foundation

public extension Encodable {
    func encodedToString() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: Double.infinity.description, negativeInfinity: Double.infinity.description, nan: "-500.0")
        let data = try encoder.encode(self)
        guard let string = String(data: data, encoding: .utf8) else {
			throw SDKError.badEncoding(message: "Impossible to encode: \(self)")
        }
        return string
    }
}
