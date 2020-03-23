//
//  PostsProcessor.swift
//  TFP
//
//  Created on 14/08/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation

class PostsProcessor {
    private let model = ProfanityModel()
    
    func process(post: String) -> SearchResult? {
//        var index = 0
        let words = post.words()
        
        for i in 0..<words.count {
            let match = model.binarySearch(for: words[i])
            guard match.type != .none else {
                continue
            }
            
            if match.type == .full {
                return match
            }
            
            if match.type == .partial {
                
                var subResult = match
                var subIndex = i
                var phrase = words[i]
                
                repeat {
                    subIndex += 1
                    
                    guard subIndex < words.count else {
                        break
                    }
                    
                    phrase += " " + words[subIndex]
                    subResult = model.binarySearch(for: phrase)
                }
                while subResult.type == .partial
                
                if subResult.type == .full {
                    return subResult
                }
            }
        }
        
        return nil
    }
}

fileprivate extension String {
    func words() -> [String] {
        
        let range = startIndex..<endIndex
        var words = [String]()
        
        enumerateSubstrings(in: range, options: .byWords) { (substring, _, _, _) in
            if let substring = substring {
                words.append(substring.lowercased())
            }
        }
        
        return words
    }
}
