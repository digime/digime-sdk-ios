//
//  CredentialCache.swift
//  DigiMeSDK
//
//  Created on 15/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Cache for securely storing credentials in the keychain
public final class CredentialCache {
    private let keychainIdPrefix = "me.digi.sdk.credentials."
        
    // Contains primary key query values
    private func baseQuery(for contractId: String) -> [NSString: AnyObject] {
        let applicationTag = (keychainIdPrefix + contractId).data(using: String.Encoding.utf8, allowLossyConversion: false)!
        return [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: applicationTag as AnyObject,
            kSecAttrKeySizeInBits: 512 as AnyObject,
        ]
    }
    
    /// Initializes an instance of credential cache
    public init() {
    }
    
    /// Retrieves the credentials for a specified contract id, if available
    /// - Parameter contractId: The contract identifier relating to the stored credentials
    /// - Returns: The credentials, if found, or nil if not found
    public func credentials(for contractId: String) -> Credentials? {
        var query = baseQuery(for: contractId)
        query[kSecReturnData] = true as AnyObject
        
        var dataTypeRef: AnyObject?
        let status = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        
        if
            status == errSecSuccess,
            let data = dataTypeRef as? Data,
            let contents = try? data.decoded() as Credentials {
            return contents
        }
        
        if status != errSecItemNotFound {
            Logger.error("OAuthToken has been set in the keychain, but could not retrieve. Error: \(status)")
        }
        
        return nil
    }
    
    /// Sets the credentials for the specified contract identifier
    /// - Parameters:
    ///   - credentials: The credentials relating to the contract identifier. If nil, removes the entry for the contract.
    ///   - contractId: The contract identifier
    public func setCredentials(_ credentials: Credentials?, for contractId: String) {
        var query = baseQuery(for: contractId)
        
        guard let data = try? credentials?.encoded() else {
            // Delete entry
            let status = SecItemDelete(query as CFDictionary)
            if status != errSecSuccess && status != errSecItemNotFound {
                Logger.error("Unable to delete stored OAuthToken in the keychain. Error: \(status)")
            }
            
            return
        }
        
        // Check to see if relevant keychain entry should be added or updated
        var status = SecItemCopyMatching(query as CFDictionary, nil)
        if status == errSecSuccess {
            // Update
            let newAttributes: [NSString: AnyObject] = [
                kSecValueData: data as AnyObject,
            ]
            
            status = SecItemUpdate(query as CFDictionary, newAttributes as CFDictionary)
            
            if status != errSecSuccess {
                Logger.error("Unable to update existing OAuthToken in the keychain. Error: \(status)")
            }
        }
        else {
            // Add
            query[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlocked
            query[kSecValueData] = data as AnyObject
            
            let status = SecItemAdd(query as CFDictionary, nil)
            assert(status == errSecSuccess, "Failed to insert the new OAuthToken in the keychain. Error: \(status)")
        }
    }
    
    /// Clear credentials for the specified contract identifier
    /// - Parameters:
    ///   - contractId: The contract identifier
    @discardableResult
    public func clearCredentials(for contractId: String) -> Bool {
        let query = baseQuery(for: contractId)
        let status: OSStatus = SecItemDelete(query as CFDictionary)

        if status == errSecSuccess {
            return true
        }
        else {
            return false
        }
    }
}
