//
//  RequestBody.swift
//  DigiMeSDK
//
//  Created on 04/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

protocol RequestBody {
    var headers: [String: String] { get }
    var data: Data { get }
}
