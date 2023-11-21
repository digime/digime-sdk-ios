//
//  APIError.swift
//  DigiMeSDK
//
//  Created on 07/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

public struct APIError: Decodable {
    public let code: String
    public let message: String
    public let reference: String?
}
