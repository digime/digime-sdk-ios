//
//  ConnectedAccount.swift
//  DigiMeSDKExample
//
//  Created on 09/03/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Foundation

struct ConnectedAccount: Codable, Identifiable {
	var id = UUID()
	var service: Service
	var sourceAccount: SourceAccount?
	var requiredReauth = false
}

extension ConnectedAccount: Equatable {
	static func == (lhs: ConnectedAccount, rhs: ConnectedAccount) -> Bool {
		return lhs.id == rhs.id
	}
}
