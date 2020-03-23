//
//  ProfanityModel.swift
//  TFP
//
//  Created on 14/08/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation

struct ProfanityModel {
    private let wordList: [String]
    private static let profanityResource = "Profanity"
    
    init() {
        guard
            let url = Bundle.main.url(forResource: ProfanityModel.profanityResource, withExtension: "plist"),
        let profanityList = NSArray(contentsOf: url) as? [String] else {
            fatalError("\(ProfanityModel.profanityResource) plist not found")
        }
        
        wordList = profanityList
    }
    
    func word(at index: Int) -> String {
        return wordList[index]
    }
}

extension ProfanityModel {
    
    var startIndex: Int {
        return wordList.startIndex
    }
    
    var endIndex: Int {
        return wordList.endIndex
    }
    
    func binarySearch(for value: String, in range: Range<Int>? = nil) -> SearchResult {
        
        let range = range ?? startIndex..<endIndex
        
        guard range.lowerBound < range.upperBound else {
            return SearchResult()
        }
        
        let size = wordList.distance(from: range.lowerBound, to: range.upperBound)
        let middle = wordList.index(range.lowerBound, offsetBy: size / 2)
        
        let phraseSet = Set(wordList[middle].components(separatedBy: " "))
        
        // straight up match
        comparison: if wordList[middle] == value {
            let match = SearchResult(index: middle, string: value, type: .full)
            return match
        }
        else if phraseSet.count > 1 {
            let valueSet = Set(value.components(separatedBy: " "))
            
            guard valueSet.count <= phraseSet.count else {
                // continue the search
                break comparison
            }
            
            let intersection = phraseSet.intersection(valueSet)
            if intersection.count > 0 {
                var matchType: MatchType = .none
                
                if intersection.count == valueSet.count && valueSet.count < phraseSet.count {
                    matchType = .partial
                }
                    
                    // check if this is actually covered by the top level straight up match.
                else if intersection.count == valueSet.count && valueSet.count == phraseSet.count {
                    
                    matchType = .full
                    
                    // order of matches matters, so verify that now
                    // retrieve original order
                    let valueArray = value.components(separatedBy: " ")
                    let phraseArray = wordList[middle].components(separatedBy: " ")
                    for i in 0..<valueArray.count {
                        if valueArray[i] != phraseArray[i] {
                            matchType = .none
                        }
                    }
                }
                
                let match = SearchResult(index: middle, string: wordList[middle], type: matchType)
                return match
            }
        }
            
        if wordList[middle] > value {
            return binarySearch(for: value, in: range.lowerBound..<middle)
        }
        else {
            return binarySearch(for: value, in: wordList.index(after: middle)..<range.upperBound)
        }
    }
}
