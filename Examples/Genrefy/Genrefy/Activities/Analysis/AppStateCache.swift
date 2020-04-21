//
//  AppStateCache.swift
//  Genrefy
//
//  Created on 10/09/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation

@objc class AppStateCache: NSObject {

    private let consentDateKey = "LastConsentDate"
    
    private var userDefaults = UserDefaults.standard
    
    func setConsentDate(consentDate: Date) {
        userDefaults.set(consentDate, forKey: consentDateKey)
    }
    
    func consentDate() -> Date? {
        return userDefaults.object(forKey: consentDateKey) as? Date
    }
}
