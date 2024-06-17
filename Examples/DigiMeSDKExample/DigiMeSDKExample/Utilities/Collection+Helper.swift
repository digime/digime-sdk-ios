//
//  Collection+Helper.swift
//  DigiMeSDKExample
//
//  Created on 13/03/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
