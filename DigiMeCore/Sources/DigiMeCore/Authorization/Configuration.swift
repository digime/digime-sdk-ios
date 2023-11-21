//
//  Configuration.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// SDK Configuration
public struct Configuration {
    
    /// Your application identifier
    public let appId: String
    
    /// Your contract identifier
    public let contractId: String
    
    /// The PKCS1 private key base 64 encoded data
    public let privateKeyData: Data
	
	/// Use external browser to authenticate. Otherwise `SFSafariViewController` will be used.
	public let authUsingExternalBrowser: Bool
    
	/// Base URL path to override default digi.me host. If not present will use the default value.
	public let baseUrl: String?
	
    /// Creates a configuration
    /// - Parameters:
    ///   - appId: Your application identifier
    ///   - contractId: Your contract identifier
    ///   - privateKey: Your PKCS1 private key in PEM format - either with or without the "-----BEGIN RSA PRIVATE KEY-----"  header and "-----END RSA PRIVATE KEY-----" footer
	///   - authUsingExternalBrowser:	By default will use `SFSafariViewController` instance or will forward authentication flow to the default browser on the device.
	///	  - baseUrl: Base URL path including version to change digi.me environment. If not present will use the default one.
    public init(appId: String, contractId: String, privateKey: String, authUsingExternalBrowser: Bool = false, baseUrl: String? = nil) throws {
        self.appId = appId
        self.contractId = contractId
        self.privateKeyData = try Crypto.base64EncodedData(from: privateKey)
		self.authUsingExternalBrowser = authUsingExternalBrowser
		self.baseUrl = baseUrl
    }
}
