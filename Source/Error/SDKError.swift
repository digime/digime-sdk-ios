//
//  SDKError.swift
//  DigiMeSDK
//
//  Created on 11/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// SDK Errors
public enum SDKError: Error {
    
    // MARK: - SDK Setup Errors
    
    /// URL Scheme not set in Info.plist
    /// This is an implementation error and can be resolved by setting the CFBundleURLSchemes in Info.plist to include "digime-ca-YOUR_APP_ID" using your actual app identifier in place of YOUR_APP_ID.
    case noUrlScheme
    
    /// App identifier is using placeholder value "YOUR_APP_ID"
    /// This is an implementation error and can be resolved by using your actual app identifier in place of YOUR_APP_ID.
    case invalidAppId
    
    /// The private or public key is invalid
    /// This is an implementation error and can be resolved by ensuring that you are using keys beginning with "-----BEGIN RSA {PRIVATE/PUBLIC} KEY----" as appropriate.
    case invalidPrivateOrPublicKey
    
    // MARK: - Runtime Errors
    
    /// The contract needs authorizing.
    /// This is either caused by the contract not having been authorized or the contract's credentials expired requiring user to reauthorize
    case authorizationRequired
    
    /// Server has returned data which cannot be read
    case invalidData
    
    /// File list time out reached as there have been no changes.
    case fileListPollingTimeout

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
    
    /// An unsuccessful HTTP response was returned from digi.me server
    case httpResponseError(statusCode: Int, apiError: APIError?)
    
    /// An error occurred while encrypting write request
    case writeRequestFailure
    
    /// Unable to encode the metadata associated with a write request
    case invalidWriteMetadata
    
    /// This SDK version is no longer supported - please update to latest version
    case invalidSdkVersion
    
    /// Requested read options are out of bounds with respect to the contract's scope
    case scopeOutOfBounds
    
    /// Attempting to read with a write contract or write with a read contract
    case incorrectContractType
    
    /// An unexpected error has occurred - please contact support
    case other
}

// MARK: - CustomStringConvertible
extension SDKError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidData:
            return "Server has returned data which cannot be read."

        case .noUrlScheme:
            return "CFBundleURLSchemes in Info.plist must include 'digime-ca-YOUR_APP_ID' using your actual app identifier in place of 'YOUR_APP_ID'."
        
        case .invalidAppId:
            return "The placeholder `YOUR_APP_ID` needs to be replaced with your actual app identifier."
        
        case .authorizationRequired:
            return "This contract either needs to be authorized for the first time or reauthorized due to expired credentials"
        
        case .fileListPollingTimeout:
            return "Retrieving files has timed out"
        
        case .invalidPrivateOrPublicKey:
            return "The private or public key is invalid. Please unsure the keys used begin with either:\n\t`-----BEGIN RSA PRIVATE KEY-----` or\n\t`-----BEGIN RSA PUBLIC KEY-----`"
        
        case .linkedContractNotAuthorized:
            return "The contract to link to has not been authorized."
        
        case .authorizationCancelled:
            return "User cancelled authorization."
        
        case .addingServiceFailed:
            return "An error occurred when adding a service."
        
        case .authorizationFailed(let code):
            return "Authorization failed with code \(code)."
        
        case .urlRequestFailed(let error):
            return "A general communication error occurred: \(error)"
        
        case let .httpResponseError(statusCode, apiError):
            var message = "An unsuccessful HTTP response was returned from digi.me server. Status code: \(statusCode)."
            if let apiError = apiError {
                message += " Error code: \(apiError.code). Error message: `\(apiError.message)`."
            }
            
            return message
        
        case .writeRequestFailure:
            return "An error occurred while encrypting write request."
        
        case .invalidWriteMetadata:
            return "Unable to encode the metadata associated with a write request."
        
        case .invalidSdkVersion:
            return "This SDK version is no longer supported - please update to latest version."
        
        case .scopeOutOfBounds:
            return "Requested read options are out of bounds with respect to the contract's scope."
        
        case .incorrectContractType:
            return "Attempting to read with a write contract or write with a read contract."
            
        case .other:
            return "An unexpected error has occurred - please contact digi.me support."
        }
    }
}
