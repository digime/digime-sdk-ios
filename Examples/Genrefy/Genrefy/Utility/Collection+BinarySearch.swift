//
//  Collection+BinarySearch.swift
//  TFP
//
//  Created on 13/08/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

public extension RandomAccessCollection where Element: Comparable, Element: Hashable {
    
    func binarySearch(for value: Element, in range: Range<Index>? = nil) -> Index? {

        let range = range ?? startIndex..<endIndex
        
        guard range.lowerBound < range.upperBound else {
            return nil
        }
        
        let size = distance(from: range.lowerBound, to: range.upperBound)
        let middle = index(range.lowerBound, offsetBy: size / 2)

        if self[middle] == value {
            return middle
        }
        else if self[middle] > value {
            return binarySearch(for: value, in: range.lowerBound..<middle)
        }
        else {
            return binarySearch(for: value, in: index(after: middle)..<range.upperBound)
        }
    }
}

