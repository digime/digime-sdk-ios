//
//  ProfanityRanker.swift
//  TFP
//
//  Created on 24/10/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation

struct ProfanityRanker {
    private static let profanityRankingResource = "Profanity_Ranking"
    private let ranking: [String: Int]
    
    init() {
        guard
            let url = Bundle.main.url(forResource: ProfanityRanker.profanityRankingResource, withExtension: "plist"),
        let rankingDict = NSDictionary(contentsOf: url) as? [String: Int] else {
                fatalError("\(ProfanityRanker.profanityRankingResource) plist not found")
        }
        
        ranking = rankingDict
    }
    
    func rankOf(_ word: String) -> Int {
        guard let val = ranking[word] else {
            return 0
        }
        
        return val
    }
}
