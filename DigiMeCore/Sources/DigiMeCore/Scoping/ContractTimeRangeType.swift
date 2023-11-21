//
//  ContractTimeRangeType.swift
//  DigiMeSDK
//
//  Created on 21/02/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

import Foundation

public enum ContractTimeRangeType: Int, Codable {
    case window
    case since
    case until
    case rolling
    case allTime
}
