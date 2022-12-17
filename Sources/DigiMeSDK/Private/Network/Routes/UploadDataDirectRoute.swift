//
//  UploadDataDirectRoute.swift
//  DigiMeSDK
//
//  Created on 06/12/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

struct UploadDataDirectRoute: Route {
	typealias ResponseType = Void
	
	static let method = "POST"
	static let path = "permission-access/import"
	
	var requestBody: RequestBody {
		return FileUploadBody(data: payload)
	}
	
	var customHeaders: [String: String] {
		[
			"Authorization": "Bearer " + jwt,
			"FileDescriptor": fileDescriptor
		]
	}
	
	let payload: Data
	let jwt: String
	let fileDescriptor: String
}
