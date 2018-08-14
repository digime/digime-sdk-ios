//
//  Enum+Collection.swift
//  DigiMe
//
//  Created on 01/02/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

/// Allows enumerations to provide all the case values
protocol EnumCollection: Hashable {
    
    /// Gets a sequence of all the enumeration's cases
    ///
    /// - Returns: All the enumeration's cases
    static func cases() -> AnySequence<Self>
    
    /// An array of all the enumeration's cases
    static var allValues: [Self] { get }
    
    /// Returns the next enumeration item, or nil if already at end
    ///
    /// - Returns: Next enumeration item, or nil if already at end
    func next() -> Self?
    
    /// Returns the previous enumeration item, or nil if already at beginning
    ///
    /// - Returns: Previous enumeration item, or nil if already at beginning
    func previous() -> Self?
}

extension EnumCollection {
    
    static func cases() -> AnySequence<Self> {
        return AnySequence { () -> AnyIterator<Self> in
            var raw = 0
            return AnyIterator {
                let current: Self = withUnsafePointer(to: &raw) {
                    $0.withMemoryRebound(to: self, capacity: 1) { $0.pointee }
                }
                guard current.hashValue == raw else {
                    return nil
                }
                
                raw += 1
                return current
            }
        }
    }
    
    static var allValues: [Self] {
        return Array(Self.cases())
    }
    
    func next() -> Self? {
        if let index = Self.allValues.index(of: self), index + 1 < Self.allValues.count {
            return Self.allValues[index + 1]
        }
        
        return nil
    }
    
    func previous() -> Self? {
        if let index = Self.allValues.index(of: self), index > 0 {
            return Self.allValues[index - 1]
        }
        
        return nil
    }
}
