//
//  DeletedObject.swift
//  DigiMeSDK
//
//  Created on 16.02.21.
//

import HealthKit

public struct DeletedObject: Codable {
    public let uuid: String
    public let metadata: Metadata?
    
    init(deletedObject: HKDeletedObject) {
        self.uuid = deletedObject.uuid.uuidString
		self.metadata = deletedObject.metadata?.asMetadata
    }
}

// MARK: - Factory
extension DeletedObject {
    public static func collect(deletedObjects: [HKDeletedObject]?) -> [DeletedObject] {
        return deletedObjects?.compactMap { DeletedObject(deletedObject: $0) } ?? []
    }
}
