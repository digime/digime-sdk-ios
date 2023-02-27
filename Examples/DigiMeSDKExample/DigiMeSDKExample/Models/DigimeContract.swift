//
//  DigimeContract.swift
//  DigiMeSDKExample
//
//  Created on 26/07/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Foundation

struct DigimeContract: Identifiable {
	var id = UUID()
    let name: String
    let identifier: String
    let privateKey: String
    let timeRanges: [TimeRange]?
}
