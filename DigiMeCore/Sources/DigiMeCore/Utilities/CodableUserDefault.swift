//
//  CodableUserDefault.swift
//  DigiMeSDK
//
//  Created on 20/06/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

@propertyWrapper
public struct CodableUserDefault<T: Codable> {
    let key: String
    var userDefaults: UserDefaults = .standard

    public var wrappedValue: T? {
        get {
            let data = userDefaults.data(forKey: key)
            return try? data?.decoded() as T?
        }
        set {
            if let newValue = newValue {
                let data = try? newValue.encoded()
                userDefaults.set(data, forKey: key)
            }
            else {
                userDefaults.removeObject(forKey: key)
            }
        }
    }
}

public extension CodableUserDefault {
    
    /// Creates a new User Defaults property wrapper for the given string raw representable key.
    /// - Parameters:
    ///   - key: The key to use with the user defaults store
    ///   - userDefaults: The user defaults store
    init<U: RawRepresentable>(key: U, userDefaults: UserDefaults = .standard) where U.RawValue == String {
        self.init(key: key.rawValue, userDefaults: userDefaults)
    }
}
