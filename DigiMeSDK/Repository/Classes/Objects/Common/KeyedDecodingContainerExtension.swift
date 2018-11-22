//
//  KeyedDecodingContainerExtension.swift
//  DigiMeRepository
//
//  Created on 26/10/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
    func decodeIntOrStringToInt(key: KeyedDecodingContainer.Key) throws -> Int? {
        var result: Int?
        if let int = try? self.decodeIfPresent(Int.self, forKey: key) {
            result = int
        }
        else if let string = try self.decodeIfPresent(String.self, forKey: key) {
            result = Int(string)
        }
        
        return result
    }
}

extension NSNumber {
    convenience init?(value: Int8?) {
        guard let nonOptional = value else {
            return nil
        }
        
        self.init(value: nonOptional)
    }
    
    convenience init?(value: UInt8?) {
        guard let nonOptional = value else {
            return nil
        }
        
        self.init(value: nonOptional)
    }
    
    convenience init?(value: Int16?) {
        guard let nonOptional = value else {
            return nil
        }
        
        self.init(value: nonOptional)
    }
    
    convenience init?(value: UInt16?) {
        guard let nonOptional = value else {
            return nil
        }
        
        self.init(value: nonOptional)
    }
    
    convenience init?(value: Int32?) {
        guard let nonOptional = value else {
            return nil
        }
        
        self.init(value: nonOptional)
    }
    
    convenience init?(value: UInt32?) {
        guard let nonOptional = value else {
            return nil
        }
        
        self.init(value: nonOptional)
    }
    convenience init?(value: Int64?) {
        guard let nonOptional = value else {
            return nil
        }
        
        self.init(value: nonOptional)
    }
    
    convenience init?(value: UInt64?) {
        guard let nonOptional = value else {
            return nil
        }
        
        self.init(value: nonOptional)
    }
    
    convenience init?(value: Int?) {
        guard let nonOptional = value else {
            return nil
        }
        
        self.init(value: nonOptional)
    }
    
    convenience init?(value: UInt?) {
        guard let nonOptional = value else {
            return nil
        }
        
        self.init(value: nonOptional)
    }
    
    convenience init?(value: Float?) {
        guard let nonOptional = value else {
            return nil
        }
        
        self.init(value: nonOptional)
    }
    
    convenience init?(value: Double?) {
        guard let nonOptional = value else {
            return nil
        }
        
        self.init(value: nonOptional)
    }
    
    convenience init?(value: Bool?) {
        guard let nonOptional = value else {
            return nil
        }
        
        self.init(value: nonOptional)
    }
}
