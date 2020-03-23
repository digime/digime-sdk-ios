//
//  TFPCache.swift
//  TFP
//
//  Created on 10/09/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation

@objc class TFPCache: NSObject {

    private let cacheKey = "TFPCacheItems"
    private let tutorialKey = "TFPTutorialDidShow"
    private let onboardingKey = "TFPOnboardingDidShow"
    private let existingUserKey = "TFPOnboardingExistingUser"
    private let consentDateKey = "TFPLastConsentDate"
    
    private var userDefaults = UserDefaults.standard
    
    func addItem(identifier: String, action: TFPAction) {
        var cachedItems = self.allRawItems()
        cachedItems[identifier] = action.rawValue
        setCachedItems(cachedItems)
    }
    
    private func setCachedItems(_ items: [String: Int]) {
        userDefaults.set(items, forKey: cacheKey)
    }
    
    func deleteItems(identifiers: Set<String>) {
        var cachedItems = self.allRawItems()
        cachedItems = cachedItems.filter({ !identifiers.contains($0.0) })
        setCachedItems(cachedItems)
    }
    
    func allItems() -> [String: TFPAction] {
        
        return allRawItems().mapValues({ TFPAction(rawValue: $0)! })
    }
    
    func allRawItems() -> [String: Int] {
        guard let items = userDefaults.object(forKey: cacheKey) as? [String: Int] else {
            return [:]
        }
        
        return items
    }
    
    func didShowTutorial(service: ServiceType) -> Bool {
        let key = tutorialKey(for: service)
        guard
            let didShow = userDefaults.object(forKey: key) as? Bool else {
                return false
        }
        
        return didShow
    }
    
    private func tutorialKey(for service: ServiceType) -> String {
        return "\(tutorialKey)_\(service.rawValue)"
    }
    
    func setTutorial(service: ServiceType, didShow: Bool) {
        let key = tutorialKey(for: service)
        userDefaults.set(didShow, forKey: key)
    }
    
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
