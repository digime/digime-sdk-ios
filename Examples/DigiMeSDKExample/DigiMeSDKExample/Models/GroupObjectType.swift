//
//  GroupObjectType.swift
//  DigiMeSDKExample
//
//  Created on 26/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Foundation

struct GroupObjectType {
	let serviceGroupId: Int
	let items: [ServiceObjectType]
	
	init(serviceGroupId: Int, items: [ServiceObjectType]) {
		self.serviceGroupId = serviceGroupId
		self.items = items
	}
}
