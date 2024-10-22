//
//  SourceRevision.swift
//  DigiMeHealthKit
//
//  Created on 25.09.20.
//

import CryptoKit
import DigiMeCore
import Foundation
import HealthKit

public struct SourceRevision: Codable, Identifiable {
    public struct OperatingSystem: Codable, Identifiable {
        public let id: String
        public let majorVersion: Int
        public let minorVersion: Int
        public let patchVersion: Int

        var original: OperatingSystemVersion {
            return OperatingSystemVersion(majorVersion: majorVersion, minorVersion: minorVersion, patchVersion: patchVersion)
        }

        init(version: OperatingSystemVersion) {
            self.majorVersion = version.majorVersion
            self.minorVersion = version.minorVersion
            self.patchVersion = version.patchVersion
            self.id = Self.generateHashId(majorVersion: self.majorVersion, minorVersion: self.minorVersion, patchVersion: self.patchVersion)
        }

        public init(majorVersion: Int, minorVersion: Int, patchVersion: Int) {
            self.majorVersion = majorVersion
            self.minorVersion = minorVersion
            self.patchVersion = patchVersion
            self.id = Self.generateHashId(majorVersion: majorVersion, minorVersion: minorVersion, patchVersion: patchVersion)
        }

        public func copyWith(majorVersion: Int? = nil, minorVersion: Int? = nil, patchVersion: Int? = nil) -> OperatingSystem {
            return OperatingSystem(
                majorVersion: majorVersion ?? self.majorVersion,
                minorVersion: minorVersion ?? self.minorVersion,
                patchVersion: patchVersion ?? self.patchVersion
            )
        }

        private static func generateHashId(majorVersion: Int, minorVersion: Int, patchVersion: Int) -> String {
            let idString = "\(majorVersion).\(minorVersion).\(patchVersion)"
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

    public let id: String
    public let source: Source
    public let version: String?
    public let productType: String?
    public let systemVersion: String
    public let operatingSystem: OperatingSystem

    init(sourceRevision: HKSourceRevision) {
        self.source = Source(source: sourceRevision.source)
        self.version = sourceRevision.version
        self.productType = sourceRevision.productType
        self.systemVersion = sourceRevision.systemVersion
        self.operatingSystem = OperatingSystem(version: sourceRevision.operatingSystemVersion)
        self.id = Self.generateHashId(
            source: self.source,
            version: self.version,
            productType: self.productType,
            systemVersion: self.systemVersion,
            operatingSystem: self.operatingSystem
        )
    }

    public init(source: Source,
                version: String?,
                productType: String?,
                systemVersion: String,
                operatingSystem: OperatingSystem) {
        self.source = source
        self.version = version
        self.productType = productType
        self.systemVersion = systemVersion
        self.operatingSystem = operatingSystem
        self.id = Self.generateHashId(
            source: source,
            version: version,
            productType: productType,
            systemVersion: systemVersion,
            operatingSystem: operatingSystem
        )
    }

    public func copyWith(source: Source? = nil,
                         version: String? = nil,
                         productType: String? = nil,
                         systemVersion: String? = nil,
                         operatingSystem: OperatingSystem? = nil) -> SourceRevision {
        return SourceRevision(
            source: source ?? self.source,
            version: version ?? self.version,
            productType: productType ?? self.productType,
            systemVersion: systemVersion ?? self.systemVersion,
            operatingSystem: operatingSystem ?? self.operatingSystem
        )
    }

    private static func generateHashId(source: Source,
                                       version: String?,
                                       productType: String?,
                                       systemVersion: String,
                                       operatingSystem: OperatingSystem) -> String {
        let idString = "\(source.id)_\(version ?? "")_\(productType ?? "")_\(systemVersion)_\(operatingSystem.id)"
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
extension SourceRevision: Original {
    func asOriginal() throws -> HKSourceRevision {
		return HKSourceRevision(source: try source.asOriginal(),
								version: version,
								productType: productType,
								operatingSystemVersion: operatingSystem.original)
	}
}

// MARK: - Payload
extension SourceRevision.OperatingSystem: Payload {
    public static func make(from dictionary: [String: Any]) throws -> SourceRevision.OperatingSystem {
        guard
            let majorVersion = dictionary["majorVersion"] as? Int,
            let minorVersion = dictionary["minorVersion"] as? Int,
            let patchVersion = dictionary["patchVersion"] as? Int else {
			
			throw SDKError.invalidValue(message: "Invalid dictionary: \(dictionary)")
        }
		
        return SourceRevision.OperatingSystem(majorVersion: majorVersion, minorVersion: minorVersion, patchVersion: patchVersion)
    }
}

// MARK: - Payload
extension SourceRevision: Payload {
    public static func make(from dictionary: [String: Any]) throws -> SourceRevision {
        guard
            let systemVersion = dictionary["systemVersion"] as? String,
            let operatingSystem = dictionary["operatingSystem"] as? [String: Any],
            let source = dictionary["source"] as? [String: Any] else {
			
			throw SDKError.invalidValue(message: "Invalid dictionary: \(dictionary)")
        }
		
        let version = dictionary["version"] as? String
        let productType = dictionary["productType"] as? String
		return SourceRevision(source: try Source.make(from: source),
							  version: version,
							  productType: productType,
							  systemVersion: systemVersion,
							  operatingSystem: try OperatingSystem.make(from: operatingSystem))
    }
}
