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

extension Array {
    public func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
