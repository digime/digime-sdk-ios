//
//  CategoriesResponse.swift
//  DigiMeSDK
//
//  Created on 07/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation

struct CategoriesResponse: Decodable {
    let data: [ServiceGroupType]?
}
