//
//  UserPreferences.swift
//  Genrefy
//
//  Created on 18/04/2023.
//  Copyright © 2023 digi.me. All rights reserved.
//

import DigiMeSDK
import Foundation

final class UserPreferences: NSObject {
    
    private let userDefaults = UserDefaults.standard
    private enum Key: String, CaseIterable {
        case credentials = "kCredentials"
    }
    
    @discardableResult
    class func shared() -> UserPreferences {
        return sharedPreferences
    }
    
    private static var sharedPreferences: UserPreferences = {
        return UserPreferences()
    }()
    
    // MARK: - Credentials
    
    @CodableUserDefault(key: Key.credentials)
    private var credentials: [String: Credentials]?
    
    func credentials(for contractId: String) -> Credentials? {
        return credentials?[contractId]
    }
    
    func setCredentials(newCredentials: Credentials, for contractId: String) {
        var cachedCredentials = credentials ?? [:]
        cachedCredentials[contractId] = newCredentials
        credentials = cachedCredentials
    }
    
    func clearCredentials(for contractId: String) {
        credentials?[contractId] = nil
    }
    
    func reset() {
        credentials = nil
    }
}

