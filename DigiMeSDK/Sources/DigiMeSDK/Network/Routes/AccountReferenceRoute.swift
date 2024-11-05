//
//  AccountReferenceRoute.swift
//  DigiMeSDK
//
//  Created on 06/03/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Foundation

struct AccountReferenceRoute: Route {
	typealias ResponseType = ReferenceResponse
	
	static var method = "POST"
	static var path = "reference"
    static let version: APIVersion = .public
    
	var requestBody: RequestBody? {
		let body = AccountReferenceBody(type: "accountId", value: accountId)
		return try? JSONRequestBody(parameters: body)
	}
	
	var customHeaders: [String: String] {
		["Authorization": "Bearer " + jwt]
	}
	
	private struct AccountReferenceBody: Encodable {
		let type: String
		let value: String
	}
	
	let jwt: String
	let accountId: String
}
