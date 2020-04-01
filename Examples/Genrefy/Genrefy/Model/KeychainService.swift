//
//  KeychainService.swift
//  Genrefy
//
//  Created on 01/04/2020.
//  Copyright © 2020 digi.me. All rights reserved.
//

import Foundation
import Security

class KeychainService: NSObject {
    
    static let shared = KeychainService()

    func updateEntry(data: Data, for key: String) {
        let keychainQuery = [
        kSecClass as String       : kSecClassGenericPassword as String,
        kSecAttrAccount as String : key,
        kSecValueData as String   : data ] as [String : Any]
        
        let status = SecItemUpdate(keychainQuery as CFDictionary, [kSecValueData as String : data] as CFDictionary)
        
        if
            status != errSecSuccess,
            let err = SecCopyErrorMessageString(status, nil) {
            print("Keychain wrapper read entry failed: \(err)")
        }
    }

    func removeEntry(for key: String) {
        let keychainQuery = [
        kSecClass as String       : kSecClassGenericPassword as String,
        kSecAttrAccount as String : key] as [String : Any]
        
        let status = SecItemDelete(keychainQuery as CFDictionary)
        if
            status != errSecSuccess,
            let err = SecCopyErrorMessageString(status, nil) {
                print("Keychain wrapper remove entry failed: \(err)")
        }
    }

    func saveEntry(data: Data, for key: String) {
        let keychainQuery = [
        kSecClass as String       : kSecClassGenericPassword as String,
        kSecAttrAccount as String : key,
        kSecValueData as String   : data ] as [String : Any]
        
        SecItemDelete(keychainQuery as CFDictionary)
        
        let status = SecItemAdd(keychainQuery as CFDictionary, nil)
        
        if
            status != errSecSuccess,
            let err = SecCopyErrorMessageString(status, nil) {
                print("Keychain wrapper write entry failed: \(err)")
        }
    }

    func loadEntry(for key: String) -> Data? {
        let keychainQuery = [
        kSecClass as String       : kSecClassGenericPassword,
        kSecAttrAccount as String : key,
        kSecReturnData as String  : kCFBooleanTrue!,
        kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]
        
        var dataTypeRef: AnyObject? = nil
        
        let status: OSStatus = SecItemCopyMatching(keychainQuery as CFDictionary, &dataTypeRef)

        guard
            status == errSecSuccess,
            let data = dataTypeRef as? Data else {
                print("Keychain wrapper nothing was retrieved from the keychain. Status code \(status)")
                return nil
        }

        return data
    }
}
