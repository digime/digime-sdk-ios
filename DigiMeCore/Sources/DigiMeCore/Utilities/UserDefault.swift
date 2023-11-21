//
//  UserDefault.swift
//  DigiMeSDK
//
//  Created on 20/06/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation
import UIKit

@propertyWrapper
public struct UserDefault<T: UserDefaultStorable> {
    let key: String
    let defaultValue: T
    var userDefaults: UserDefaults = .standard
    var persistDefaultValue = false // This will persist any default value when it is first read

    public var wrappedValue: T {
        get {
            if let value = userDefaults.object(forKey: key) as? T {
                return value
            }
            
            if persistDefaultValue {
                userDefaults.set(defaultValue, forKey: key)
            }
            
            return defaultValue
        }
        set {
            // Check whether we're dealing with an optional and remove the object if the new value is nil.
            if let optional = newValue as? AnyOptional, optional.isNil {
                userDefaults.removeObject(forKey: key)
            }
            else {
                userDefaults.set(newValue, forKey: key)
            }
        }
    }
}

public protocol UserDefaultStorable { }

extension Int: UserDefaultStorable { }
extension Bool: UserDefaultStorable { }
extension Date: UserDefaultStorable { }
extension String: UserDefaultStorable { }
extension Data: UserDefaultStorable { }
extension CGFloat: UserDefaultStorable { }
extension Optional: UserDefaultStorable where Wrapped: UserDefaultStorable { }

fileprivate protocol AnyOptional {
    /// Returns `true` if `nil`, otherwise `false`.
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}

public extension UserDefault {
    
    /// Creates a new User Defaults property wrapper for the given string raw representable key.
    /// - Parameters:
    ///   - key: The key to use with the user defaults store
    ///   - defaultValue: The value to return of the key is not present in the store
    ///   - userDefaults: The user defaults store
    ///   - persistDefaultValue: Whether the default value should be persisted to the store if the key is not present when first read.
    init<U: RawRepresentable>(key: U, defaultValue: T, userDefaults: UserDefaults = .standard, persistDefaultValue: Bool = false) where U.RawValue == String {
        self.init(key: key.rawValue, defaultValue: defaultValue, userDefaults: userDefaults, persistDefaultValue: persistDefaultValue)
    }
}

public extension UserDefault where T: ExpressibleByNilLiteral {
    
    /// Creates a new User Defaults property wrapper for the given key.
    /// - Parameters:
    ///   - key: The key to use with the user defaults store.
    ///   - userDefaults: The user defaults store
    init(key: String, userDefaults: UserDefaults = .standard) {
        self.init(key: key, defaultValue: nil, userDefaults: userDefaults)
    }
    
    /// Creates a new User Defaults property wrapper for the given string raw representable key.
    /// - Parameters:
    ///   - key: The key to use with the user defaults store.
    ///   - userDefaults: The user defaults store
    init<U: RawRepresentable>(key: U, userDefaults: UserDefaults = .standard) where U.RawValue == String {
        self.init(key: key.rawValue, defaultValue: nil, userDefaults: userDefaults)
    }
}
