//
//  Array+Helper.swift
//  DigiMeSDK
//
//  Created on 27/02/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {
            return
        }
        
        remove(at: index)
    }
}
