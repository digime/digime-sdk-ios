//
//  HTTPError.swift
//  DigiMeSDK
//
//  Created on 07/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

enum HTTPError: Error {
    case noResponse
    case noData
    case unsuccesfulStatusCode(Int, response: ErrorResponse?)
}
