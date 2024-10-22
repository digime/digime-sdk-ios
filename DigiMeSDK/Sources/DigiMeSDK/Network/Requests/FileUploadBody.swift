//
//  FileImportBody.swift
//  DigiMeSDK
//
//  Created by on 14/12/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

struct FileUploadBody: RequestBody {
	var headers: [String: String] {
		[
			"Content-Type": "application/octet-stream",
			"Accept": "application/json",
		]
	}
	
	var data: Data
}
