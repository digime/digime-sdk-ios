//
//  JSONRequestBody.swift
//  DigiMeSDK
//
//  Created on 04/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct JSONRequestBody: RequestBody {
    let headers = ["Content-Type": "application/json"]
    let data: Data
    
    init(parameters: [String: Any]) throws {
        data = try JSONSerialization.data(withJSONObject: parameters, options: [])
    }
    
    init<T: Encodable>(parameters: T) throws {
		data = try parameters.encoded(dateEncodingStrategy: .millisecondsSince1970)
    }
}
