//
//  UploadMixpanelEventsRoute.swift
//  DigiMeSDK
//
//  Created on 11/08/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

struct UploadMixpanelEventsRoute: Route {
	typealias ResponseType = LogEventsUploadResponse
	
	static let method = "POST"
	static let path = "tracking/sdk"
	
	var customHeaders: [String: String] {
		["Authorization": "Bearer " + jwt]
	}
	
	var requestBody: RequestBody? {
		return body
	}
	
	let body: RequestBody
	let jwt: String
}
