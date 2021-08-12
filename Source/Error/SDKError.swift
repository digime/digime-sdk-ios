//
//  SDKError.swift
//  DigiMeSDK
//
//  Created on 11/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Unrecoverable SDK Errors
public enum SDKError: Error {
    
    /// Server has returned data which cannot be read
    case invalidData
    
    /// URL Scheme not set in Info.plist
    /// This is an implementation error and can be resolved by setting the CFBundleURLSchemes in Info.plist to include "digime-ca-YOUR_APP_ID using your actual app identifier in place of YOUR_APP_ID.
    case noUrlScheme
    
    /// App identifier is using placeholder value "YOUR_APP_ID"
    /// This is an implementation error and can be resolved by using your actual app identifier in place of YOUR_APP_ID.
    case invalidAppId
    
    /// The contract needs authorizing.
    /// This is either caused by the contract not having been authorized or the contract's credentials expired requiring user to reauthorize
    case authorizationRequired
    
    /// File list time out reached as there have been no changes.
    case fileListPollingTimeout
    
    /// The private or public key is invalid
    /// This is an implementation error and can be resolved by ensuring that you are using keys beginning with "-----BEGIN RSA {PRIVATE/PUBLIC} KEY----" as appropriate.
    case invalidPrivateOrPublicKey
    
    /// The contract to link to has not been authorized
    case linkedContractNotAuthorized
    
    /// User cancelled authorization
    case authorizationCancelled
    
    /// An error occurred when adding a service
    case addingServiceFailed
    
    /// Authorization failed with the specified code
    case authorizationFailed(code: String)
    
    /// An error occurred when communicating with digi.me server. Contains underlying error - typically an instance of URLError
    case urlRequestFailed(error: Error)
    
    // An unsuccessful HTTP response was returned from digi.me server
    case httpResponseError(statusCode: Int, apiError: APIError?)
    
    /// An error occurred while encrypting write request
    case writeRequestFailure
    
    /// Unable to encode the metadata associated with a write request
    case invalidWriteMetadata
    
    /// This SDK version is no longer supported - please update to latest version
    case invalidSdkVersion
    
    /// Requested read options are out of bounds with respect to the contract's scope
    case scopeOutOfBounds
    
    /// An unexpected error has occurred - please contact support
    case other
}

/*
 typedef NS_ENUM(NSInteger, AuthError) {
     AuthErrorGeneral = 1, // general error
     AuthErrorCancelled = 5, // authorization cancelled
     AuthErrorInvalidSession = 7, //invalid session
     AuthErrorInvalidSessionKey = 10, //session key returned by digi.me app is invalid
     AuthErrorScopeOutOfBounds = 11, // requested scope is out of bounds of Contract scope
     AuthErrorOAuthTokenExpired = 12, // OAuthToken expired. Use `authorize` without token to refresh.
 };
 
 typedef NS_ENUM(NSInteger, SDKError) {
     SDKErrorNoContract = 1,         // No contract id set
     SDKErrorInvalidContract = 2,    // Contract id has invalid format
     SDKErrorDecryptionFailed = 3,   // Could not decrypt file content
     SDKErrorInvalidData = 4,        // Could not serialize data
     SDKErrorInvalidVersion = 5,     // This SDK version is no longer supported
     SDKErrorNoAppId = 6,            // No app id set
     SDKErrorNoPrivateKeyHex = 7,    // No private key hex set
     SDKErrorNoURLScheme = 8,        // URL Scheme not set in Info.plist
     SDKErrorDigiMeAppNotFound = 11, // Querying the 'digime' schema failed.
     SDKErrorFileListPollingTimeout = 12, // File List time out reached as there have been no changes.
     SDKErrorOAuthTokenNotSet = 13, // OAuth token not set on client instance.
     SDKErrorIncorrectContractType = 14, // Attempting to call ongoing API with a one-off contract.
 };
 */

extension SDKError: CustomStringConvertible {
    public var description: String {
        return "MCE \(self)"
    }
}
