//
//  FileListCache.swift
//  DigiMeSDK
//
//  Created on 03/08/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

class FileListCache {
    
    private var cache = [String: Date]()

    func newItems(from items: [FileListItem]) -> [FileListItem] {
        return items.filter { item in
            guard let existingItem = cache[item.name] else {
                return true
            }

            return existingItem < item.updatedDate
        }
    }

    func add(items: [FileListItem]) {
        items.forEach { cache[$0.name] = $0.updatedDate }
    }
    
    func reset() {
        cache = [:]
    }
}
