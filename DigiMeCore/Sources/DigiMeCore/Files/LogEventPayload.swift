//
//  LogEventPayload.swift
//  DigiMeSDK
//
//  Created on 11/08/2022.
//  Copyright © 2022 digi.me Limited. All rights rserved.
//

import Foundation

public struct LogEventPayload: Encodable {
	let agent: LogEventAgent
	let events: [LogEvent]
    
    public init(agent: LogEventAgent, events: [LogEvent]) {
        self.agent = agent
        self.events = events
    }
}

public struct Agent: Encodable {
    public let name: String
    public let version: String
    
    public init(name: String, version: String) {
        self.name = name
        self.version = version
    }
}

public struct LogEventAgent: Encodable {
	let sdk: Agent
    
    public init(sdk: Agent) {
        self.sdk = sdk
    }
}

public struct LogEvent: Codable {
	let event: String
	let timestamp: Int
	let distinctId: String
	let meta: LogEventMeta
    
    public init(event: String, timestamp: Int, distinctId: String, meta: LogEventMeta) {
        self.event = event
        self.timestamp = timestamp
        self.distinctId = distinctId
        self.meta = meta
    }
}

public struct LogEventMeta: Codable {
    public let service: [String]
    public let servicegroup: [String]
    public var appname: String? = nil
    public var code: String? = nil
    public var message: String? = nil
    
    public init(service: [String], servicegroup: [String], appname: String? = nil, code: String? = nil, message: String? = nil) {
        self.service = service
        self.servicegroup = servicegroup
        self.appname = appname
        self.code = code
        self.message = message
    }
}
