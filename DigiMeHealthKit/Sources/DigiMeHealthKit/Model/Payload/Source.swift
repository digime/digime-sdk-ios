//
//  Source.swift
//  DigiMeHealthKit
//
//  Created on 25.09.20.
//

import CryptoKit
import DigiMeCore
import Foundation
import HealthKit

public struct Source: Hashable, Codable, Identifiable {
    public let id: String
    public let name: String
    public let bundleIdentifier: String

    init(source: HKSource) {
        self.name = source.name
        self.bundleIdentifier = source.bundleIdentifier
        self.id = Self.generateHashId(name: self.name, bundleIdentifier: self.bundleIdentifier)
    }

    public init(name: String, bundleIdentifier: String) {
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.id = Self.generateHashId(name: name, bundleIdentifier: bundleIdentifier)
    }

    public func copyWith(name: String? = nil, bundleIdentifier: String? = nil) -> Source {
        return Source(
            name: name ?? self.name,
            bundleIdentifier: bundleIdentifier ?? self.bundleIdentifier
        )
    }

    private static func generateHashId(name: String, bundleIdentifier: String) -> String {
        let idString = "\(name)_\(bundleIdentifier)"
        let inputData = Data(idString.utf8)
        let hashed = SHA256.hash(data: inputData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()

        return String(format: "%@-%@-%@-%@-%@",
                      String(hashString.prefix(8)),
                      String(hashString.dropFirst(8).prefix(4)),
                      String(hashString.dropFirst(12).prefix(4)),
                      String(hashString.dropFirst(16).prefix(4)),
                      String(hashString.dropFirst(20).prefix(12))
        )
    }
}

// MARK: - Original
extension Source: Original {
    func asOriginal() throws -> HKSource {
        return HKSource.default()
    }
}

// MARK: - Payload
extension Source: Payload {
    public static func make(from dictionary: [String: Any]) throws -> Source {
        guard
            let name = dictionary["name"] as? String,
            let bundleIdentifier = dictionary["bundleIdentifier"] as? String
        else {
			throw SDKError.invalidValue(message: "Invalid dictionary: \(dictionary)")
        }
        return Source(name: name, bundleIdentifier: bundleIdentifier)
    }
}
