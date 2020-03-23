//
//  TFPost.swift
//  TFP
//
//  Created on 14/08/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation

enum TFPAction: Int {
    case undecided = 0
    case delete // user marked for deletion
    case ignore // user decided it is harmless
    case confirmed //user did delete
}

@objc class TFPost: NSObject {
    let postObject: CAResponseObject
    let matchedWord: String
    let matchedIndex: Int
    var action: TFPAction = .undecided
    
    init(postObject object: CAResponseObject, matchedWord: String, matchedIndex: Int) {
        self.postObject = object
        self.matchedWord = matchedWord
        self.matchedIndex = matchedIndex
    }
}
