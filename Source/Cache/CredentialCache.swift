//
//  CredentialCache.swift
//  DigiMeSDK
//
//  Created on 15/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

class CredentialCache: Caching {
    private let keychainId = "me.digi.sdk.credentials"
    
    private var keychainIdData: Data {
        return keychainId.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
    
    var contents: Credentials? {
        get {
            let query: [NSString: AnyObject] = [
                kSecClass: kSecClassKey,
                kSecAttrApplicationTag: keychainIdData as AnyObject,
                kSecAttrKeySizeInBits: 512 as AnyObject,
                kSecReturnData: true as AnyObject,
            ]
            
            var dataTypeRef: AnyObject?
            let status = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
            
            if
                status == errSecSuccess,
                let data = dataTypeRef as? Data,
                let contents = try? data.decoded() as Credentials {
                return contents
            }
            
            NSLog("OAuthToken has been set in the keychain, but could not retrieve. Error: \(status)")
            return nil
        }
        
        set {
            guard let data = try? newValue?.encoded() else {
                // Delete entry
                let query: [NSString: AnyObject] = [
                    kSecClass: kSecClassKey,
                    kSecAttrApplicationTag: keychainIdData as AnyObject,
                ]
                
                let status = SecItemDelete(query as CFDictionary)
                if status != errSecSuccess || status != errSecItemNotFound {
                    NSLog("Unable to delete stored OAuthToken in the keychain. Error: \(status)")
                }
                
                return
            }
            
            // Check to see if relevant keychain entry should be added or updated
            var query: [NSString: AnyObject] = [
                kSecClass: kSecClassKey,
                kSecAttrApplicationTag: keychainIdData as AnyObject,
            ]
            
            var status = SecItemCopyMatching(query as CFDictionary, nil)
            if status == errSecSuccess {
                // Update
                let newAttributes: [NSString: AnyObject] = [
                    kSecValueData: data as AnyObject,
                ]
                
                status = SecItemUpdate(query as CFDictionary, newAttributes as CFDictionary)
                
                if status != errSecSuccess {
                    NSLog("Unable to update existing OAuthToken in the keychain. Error: \(status)")
                }
            }
            else {
                // Add
                query[kSecAttrKeySizeInBits] = 512 as AnyObject
                query[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlocked
                query[kSecValueData] = data as AnyObject
                
                let status = SecItemAdd(query as CFDictionary, nil)
                assert(status == errSecSuccess, "Failed to insert the new OAuthToken in the keychain. Error: \(status)")
            }
        }
    }
    
    let lastUpdate = Date.distantPast
}
