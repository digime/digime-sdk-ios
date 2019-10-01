//
//  DMEFileListCache.swift
//  DigiMeSDK
//
//  Created on 13/08/2019.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import UIKit

@objcMembers
public class DMEFileListCache: NSObject {

    private var cache: [String: Date] = [:]
    var allItems: [DMEFileListItem] {
        return cache.map {
            DMEFileListItem(name: $0, updateDate: $1)
        }
    }
    
    public func reset() {
        cache = [:]
    }
    
    public func newItemsFromList(_ items: [DMEFileListItem]) -> [DMEFileListItem] {
        return items.filter {
            guard let existingItem = cache[$0.name] else {
                return true
            }
            
            return existingItem < $0.updateDate
        }
    }
    
    public func cacheItems(_ items: [DMEFileListItem]) {
        items.forEach {
            cache[$0.name] = $0.updateDate
        }
    }
}
