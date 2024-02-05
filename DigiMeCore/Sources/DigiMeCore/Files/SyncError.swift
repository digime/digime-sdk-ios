//
//  SyncError.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Reason why connecting to source or importing data from source into user's library failed
public struct SyncError: Decodable, Equatable {
    public let code: String
    public let message: String?
    public let statusCode: Int?
    public let retryAfter: Date?
    public let error: ServiceError?
}

public struct ServiceError: Decodable, Equatable {
    public let message: String
    public let statusCode: Int?
    public let retryAfter: Date?
	public let reauth: Bool?
}
