//
//  AppStateCache.swift
//  Genrefy
//
//  Created on 10/09/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation

@objc class AppStateCache: NSObject {

    private let onboardingKey = "OnboardingDidShow"
    private let existingUserKey = "OnboardingExistingUser"
    private let consentDateKey = "LastConsentDate"
    
    private var userDefaults = UserDefaults.standard
    
    func setOnboarding(value: Bool?) {
        userDefaults.set(value, forKey: onboardingKey)
    }
    
    func didShowOnboarding() -> Bool {
        return userDefaults.bool(forKey: onboardingKey)
    }
    
    func setExistingUser(value: Bool?) {
        userDefaults.set(value, forKey: existingUserKey)
    }
    
    func isExistingUser() -> Bool {
        return userDefaults.bool(forKey: existingUserKey)
    }
    
    func setConsentDate(consentDate: Date) {
        userDefaults.set(consentDate, forKey: consentDateKey)
    }
    
    func consentDate() -> Date? {
        return userDefaults.object(forKey: consentDateKey) as? Date
    }
}
