//
//  GroupObjectType.swift
//  DigiMeSDKExample
//
//  Created on 26/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Foundation

struct GroupObjectType: Identifiable {
	let id: UInt
	let items: [ServiceObjectType]
	
	init(identifier: UInt, items: [ServiceObjectType]) {
		self.id = identifier
		self.items = items
	}
}
