//
//  LinkedAccount.swift
//  DigiMeSDKExample
//
//  Created on 09/03/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeCore
import DigiMeSDK
import Foundation

struct LinkedAccount: Codable, Identifiable {
	var id = UUID()
	var service: Service
	var sourceAccount: SourceAccountData?
	var requiredReauth = false
    var selectedObjectTypeIds = Set<Int>()
    var defaultObjectTypes: [ServiceObjectType] {
        guard let serviceGroupId = service.serviceGroupIds.first else {
            return []
        }
        
        return TestServiceObjectTypesByGroups.data.first { $0.id == serviceGroupId }?.items ?? []
    }
}

extension LinkedAccount: Equatable {
	static func == (lhs: LinkedAccount, rhs: LinkedAccount) -> Bool {
		return lhs.id == rhs.id
	}
}
