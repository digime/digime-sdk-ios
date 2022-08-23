//
//  LogEventPayload.swift
//  DigiMeSDK
//
//  Created on 11/08/2022.
//  Copyright © 2022 digi.me Limited. All rights rserved.
//

import Foundation

struct LogEventPayload: Encodable {
	let agent: LogEventAgent
	let events: [LogEvent]
}

struct LogEventAgent: Encodable {
	let sdk: Agent
}

struct LogEvent: Codable {
	let event: String
	let timestamp: Int
	let distinctId: String
	let meta: LogEventMeta
}

struct LogEventMeta: Codable {
	let service: [String]
	let servicegroup: [String]
	var appname: String? = nil
	var code: String? = nil
	var message: String? = nil
}
