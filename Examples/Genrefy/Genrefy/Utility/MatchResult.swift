//
//  MatchResult.swift
//  TFP
//
//  Created on 13/08/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation
import UIKit

enum MatchType {
    case none
    case partial
    case full
}

struct SearchResult {
    var type: MatchType
    var matchedString: String?
    var index: Int?
    
    init(index: Int? = nil, string: String? = nil, type: MatchType = .none) {
        self.index = index
        self.matchedString = string
        self.type = type
    }
}
