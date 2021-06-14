//
//  JWTUtility.swift
//  DigiMeSDK
//
//  Created on 04/12/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

import CryptoKit
import Foundation
import SwiftJWT

extension OAuthToken: Claims {
}

class JWTUtility: NSObject {
   
    // Default JWT header
    class var header: Header {
        Header(typ: "JWT")
    }

    // claims to request a pre-authorization code
    struct PayloadRequestPreauthJWT: Claims {
        let clientId: String
        let codeChallenge: String
        let codeChallengeMethod = "S256"
        let nonce = JWTUtility.generateNonce()
        let redirectUri: String
        let responseMode = "query"
        let responseType = "code"
        let state = JWTUtility.secureRandomHexString(length: 32)
        let timestamp = Date()
        
        init(clientId: String, codeChallenge: String, redirectUri: String) {
            self.clientId = clientId
            self.codeChallenge = codeChallenge
            self.redirectUri = redirectUri
        }
        
        func encode() throws -> String {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dateEncodingStrategy = .millisecondsSince1970
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            let data = try jsonEncoder.encode(self)
            return JWTEncoder.base64urlEncodedString(data: data)
        }
    }
    
    // claims to validate pre-authorization code
    struct PayloadValidatePreauthJWT: Claims {
        var preAuthCode: String

        enum CodingKeys: String, CodingKey {
            case preAuthCode = "preauthorization_code"
        }
    }
    
    // claims to request a authorization code
    struct PayloadRequestAuthJWT: Claims {
        let clientId: String
        let code: String
        let codeVerifier: String
        let grantType = "authorization_code"
        let nonce = JWTUtility.generateNonce()
        let redirectUri: String
        let timestamp = Date()
        
        init(clientId: String, code: String, codeVerifier: String, redirectUri: String) {
            self.clientId = clientId
            self.code = code
            self.codeVerifier = codeVerifier
            self.redirectUri = redirectUri
        }
        
        func encode() throws -> String {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dateEncodingStrategy = .millisecondsSince1970
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            let data = try jsonEncoder.encode(self)
            return JWTEncoder.base64urlEncodedString(data: data)
        }
    }
    
    // claims to request data trigger
    struct PayloadDataTriggerJWT: Claims {
        let accessToken: String
        let clientId: String
        let nonce = JWTUtility.generateNonce()
        let redirectUri: String
        let timestamp = Date()

        init(accessToken: String, clientId: String, redirectUri: String) {
            self.accessToken = accessToken
            self.clientId = clientId
            self.redirectUri = redirectUri
        }
        
        func encode() throws -> String {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dateEncodingStrategy = .millisecondsSince1970
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            let data = try jsonEncoder.encode(self)
            return JWTEncoder.base64urlEncodedString(data: data)
        }
    }
    
    // claims to request OAuth token renewal
    struct PayloadRefreshOAuthJWT: Claims {
        let clientId: String
        let grantType = "refresh_token"
        let nonce = JWTUtility.generateNonce()
        let redirectUri: String
        let refreshToken: String
        let timestamp = Date()
        
        init(refreshToken: String, clientId: String, redirectUri: String) {
            self.refreshToken = refreshToken
            self.clientId = clientId
            self.redirectUri = redirectUri
        }
        
        func encode() throws -> String {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dateEncodingStrategy = .millisecondsSince1970
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            let data = try jsonEncoder.encode(self)
            return JWTEncoder.base64urlEncodedString(data: data)
        }
    }
    
    class PayloadWriteJWT: Claims {
        let accessToken: String
        let clientId: String
        let iv: String
        let metadata: String
        let nonce = JWTUtility.generateNonce()
        let redirectUri: String
        let symmetricalKey: String
        let timestamp = Date()
        
        init(accessToken: String, clientId: String, iv: String, metadata: String, redirectUri: String, symmetricalKey: String) {
            self.accessToken = accessToken
            self.clientId = clientId
            self.iv = iv
            self.metadata = metadata
            self.redirectUri = redirectUri
            self.symmetricalKey = symmetricalKey
        }
        
        func encode() throws -> String {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dateEncodingStrategy = .millisecondsSince1970
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            let data = try jsonEncoder.encode(self)
            return JWTEncoder.base64urlEncodedString(data: data)
        }
    }

    /// Creates request JWT which can be used to get a preAuthentication token
    ///
    /// - Parameters:
    ///   - configuration: this SDK's instance configuration
    class func preAuthorizationRequestJWT(configuration: Configuration) -> String? {
        guard let privateKeyData = convertKeyString(configuration.privateKey) else {
            print("DigiMeSDK: Error creating RSA key")
            return nil
        }
        
        let randomBytes = secureRandomData(length: 32)
        let codeVerifier = randomBytes.base64URLEncodedString()
        let codeChallenge = Data(SHA256.hash(data: codeVerifier.data(using: .utf8)!)).base64URLEncodedString()
        saveCodeVerifier(codeVerifier)
        
        let claims = PayloadRequestPreauthJWT(
            clientId: configuration.clientId,
            codeChallenge: codeChallenge,
            
            // NB! this redirect schema must exist in the contract definition, otherwise preauth request will fail!
            redirectUri: configuration.redirectUri + "auth"
        )

        // signing
        var jwt = JWT(header: header, claims: claims)
        let signer = JWTSigner.ps512(privateKey: privateKeyData)
        guard let signedJwt = try? jwt.sign(using: signer) else {
            print("DigiMeSDK: Error signing preAuth JWT")
            return nil
        }

        // validation
        guard
            let publicKeyBase64 = configuration.publicKey,
            let publicKey = convertKeyString(publicKeyBase64) else {
                return signedJwt
        }
        
        let verifier = JWTVerifier.ps512(publicKey: publicKey)
        let isVerified = JWT<PayloadRequestPreauthJWT>.verify(signedJwt, using: verifier)

        return isVerified ? signedJwt : nil
    }
    
    /// Creates request JWT which can be used to get an authentication token
    /// - Parameters:
    ///   - authCode: OAuth authorization code
    ///   - configuration: this SDK's instance configuration
    class func authorizationRequestJWT(authCode: String, configuration: Configuration) -> String? {
        guard let privateKeyData = convertKeyString(configuration.privateKey) else {
            print("DigiMeSDK: Error creating RSA key")
            return nil
        }

        let claims = PayloadRequestAuthJWT(
            clientId: configuration.clientId,
            code: authCode,
            codeVerifier: retrieveCodeVerifier()!,
            
            // NB! this redirect schema must exist in the contract definition, otherwise preauth request will fail!
            redirectUri: configuration.redirectUri + "auth"
        )

        // signing
        var jwt = JWT(header: header, claims: claims)
        let signer = JWTSigner.ps512(privateKey: privateKeyData)
        guard let signedJwt = try? jwt.sign(using: signer) else {
            print("DigiMeSDK: Error signing auth JWT")
            return nil
        }

        // validation
        guard
            let publicKeyBase64 = configuration.publicKey,
            let publicKey = convertKeyString(publicKeyBase64) else {
                return signedJwt
        }
        
        let verifier = JWTVerifier.ps512(publicKey: publicKey)
        let isVerified = JWT<PayloadRequestAuthJWT>.verify(signedJwt, using: verifier)

        return isVerified ? signedJwt : nil
    }
    
    /// Extracts preAuthorization code from JWT
    /// - Parameters:
    ///   - keySet: JSON Web Key StoSetre
    ///   - jwt: pre-authorization code wrapped in JWT
    class func preAuthCode(from jwt: String, keySet: JSONWebKeySet) -> Result<String, Error> {
        let decoder = JWTDecoder { kid in
            guard
                let key = keySet.keys.first(where: { $0.kid == kid }),
                let data = convertKeyString(key.pem) else {
                NSLog("Error retrieving matching JWT verifier")
                return nil
            }
            
            return JWTVerifier.ps512(publicKey: data)
        }
        
        return Result {
            let decodedJwt = try decoder.decode(JWT<PayloadValidatePreauthJWT>.self, fromString: jwt)
            return decodedJwt.claims.preAuthCode
        }
    }
    
    /// Extracts access and refresh tokens from JWT, and wraps in `OAuthToken`.
    /// - Parameters
    ///  - jwt: JSON Web Token containing access/refresh token pair.
    ///  - publicKey: public key in base 64 format
    class func oAuthToken(from jwt: String, keySet: JSONWebKeySet) -> Result<OAuthToken, Error> {
        let decoder = JWTDecoder { kid in
            guard
                let key = keySet.keys.first(where: { $0.kid == kid }),
                let data = convertKeyString(key.pem) else {
                NSLog("Error retrieving matching JWT verifier")
                return nil
            }
            
            return JWTVerifier.ps512(publicKey: data)
        }
        
        return Result {
            let decodedJwt = try decoder.decode(JWT<OAuthToken>.self, fromString: jwt)
            return decodedJwt.claims
        }
    }
    
    /// Creates request JWT which can be used to trigger data
    /// - Parameters:
    ///   - accessToken: OAuth access token
    ///   - configuration: this SDK's instance configuration
    class func dataTriggerRequestJWT(accessToken: String, configuration: Configuration) -> String? {
        guard let privateKeyData = convertKeyString(configuration.privateKey) else {
            print("DigiMeSDK: Error creating RSA key")
            return nil
        }
        
        let claims = PayloadDataTriggerJWT(
            accessToken: accessToken,
            clientId: configuration.clientId,
            redirectUri: configuration.redirectUri
        )

        // signing
        var jwt = JWT(header: header, claims: claims)
        let signer = JWTSigner.ps512(privateKey: privateKeyData)
        guard let signedJwt = try? jwt.sign(using: signer) else {
            print("DigiMeSDK: Error signing data trigger JWT")
            return nil
        }

        // validation
        guard
            let publicKeyBase64 = configuration.publicKey,
            let publicKeyData = convertKeyString(publicKeyBase64) else {
                return signedJwt
        }
        
        let verifier = JWTVerifier.ps512(publicKey: publicKeyData)
        let isVerified = JWT<PayloadDataTriggerJWT>.verify(signedJwt, using: verifier)

        return isVerified ? signedJwt : nil
    }
    
    /// Creates request JWT which can be used to refresh oauth tokens
    /// - Parameters:
    ///   - refreshToken: OAuth refresh token
    ///   - configuration: this SDK's instance configuration
    class func refreshTokensRequestJWT(refreshToken: String, configuration: Configuration) -> String? {
        guard let privateKeyData = convertKeyString(configuration.privateKey) else {
            print("DigiMeSDK: Error creating RSA key")
            return nil
        }
        
        let claims = PayloadRefreshOAuthJWT(
            refreshToken: refreshToken,
            clientId: configuration.clientId,
            redirectUri: configuration.redirectUri
        )

        // signing
        var jwt = JWT(header: header, claims: claims)
        let signer = JWTSigner.ps512(privateKey: privateKeyData)
        guard let signedJwt = try? jwt.sign(using: signer) else {
            print("DigiMeSDK: Error signing our test token")
            return nil
        }

        // validation
        guard
            let publicKeyBase64 = configuration.publicKey,
            let publicKeyData = convertKeyString(publicKeyBase64) else {
                return signedJwt
        }
        
        let verifier = JWTVerifier.ps512(publicKey: publicKeyData)
        let isVerified = JWT<PayloadRefreshOAuthJWT>.verify(signedJwt, using: verifier)

        return isVerified ? signedJwt : nil
    }
    
    /// Creates request JWT which can be used to write data
    /// - Parameters:
    ///   - accessToken: OAuth refresh token
    ///   - iv: iv used to encrypt data
    ///   - metadat: metadata describing data being pushed
    ///   - symmetricalKey: symmetrical key used to encrypt data
    ///   - configuration: this SDK's instance configuration
    class func writeRequestJWT(accessToken: String, iv: String, metadata: String, symmetricalKey: String, configuration: Configuration) -> String? {
        guard let privateKeyData = convertKeyString(configuration.privateKey) else {
            print("DigiMeSDK: Error creating RSA key")
            return nil
        }
        let claims = PayloadWriteJWT(
            accessToken: accessToken,
            clientId: configuration.clientId,
            iv: iv,
            metadata: metadata,
            redirectUri: configuration.redirectUri,
            symmetricalKey: symmetricalKey
        )

        // signing
        var jwt = JWT(header: header, claims: claims)
        let signer = JWTSigner.ps512(privateKey: privateKeyData)
        guard let signedJwt = try? jwt.sign(using: signer) else {
            print("DigiMeSDK: Error signing our test token")
            return nil
        }

        // validation
        guard
            let publicKeyBase64 = configuration.publicKey,
            let publicKeyData = convertKeyString(publicKeyBase64) else {
                return signedJwt
        }

        let verifier = JWTVerifier.ps512(publicKey: publicKeyData)
        let isVerified = JWT<PayloadRefreshOAuthJWT>.verify(signedJwt, using: verifier)

        return isVerified ? signedJwt : nil
    }
    
    // MARK: - Utility functions
    
    private class func generateNonce() -> String {
        secureRandomHexString(length: 16)
    }
    
    private class func secureRandomHexString(length: Int) -> String {
        secureRandomBytes(length: length)
            .map { String(format: "%02x", $0) }
            .joined()
    }
    
    private class func secureRandomData(length: Int) -> Data {
        Data(bytes: secureRandomBytes(length: length))
    }
    
    private class func secureRandomBytes(length: Int) -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        if status != errSecSuccess {
            NSLog("Error generating secure random bytes. Status: \(status)")
        }
        
        return bytes
    }
    
    private class func convertKeyString(_ keyString: String) -> Data? {
        guard let base64String = base64String(for: keyString) else {
            print("Couldn't read a key string")
            return nil
        }

        return convertKeyBase64ToData(base64String)
    }
    
    private class func convertKeyBase64ToData(_ base64KeyString: String) -> Data? {
        guard let publicKeyData = Data(base64Encoded: base64KeyString, options: [.ignoreUnknownCharacters]) else {
            print("Couldn't decode base64 key")
            return nil
        }

        return publicKeyData
    }
    
    ///
    /// Get the Base64 representation of a PEM encoded string after stripping off the PEM markers.
    ///
    /// - Parameters:
    ///        - pemString:        `String` containing PEM formatted data.
    ///
    /// - Returns:                Base64 encoded `String` containing the data.
    ///
    private class func base64String(for pemString: String) -> String? {
        
        // Filter looking for new lines...
        var lines = pemString
            .components(separatedBy: "\n")
            .filter { !$0.hasPrefix("-----BEGIN") && !$0.hasPrefix("-----END") }
        
        // No lines, no data...
        guard !lines.isEmpty else {
            return nil
        }
        
        return lines
            .map { $0.replacingOccurrences(of: "\r", with: "") }
            .joined()
    }
}

// MARK: - Utility extensions

extension JWTUtility {
    static let codeVerifier: String = "me.digi.sdk.codeVerifier"
    
    // save code verifier for OAuth session
    class func saveCodeVerifier(_ codeVerifier: String) {
        let defaults = UserDefaults.standard
        defaults.set(codeVerifier, forKey: JWTUtility.codeVerifier)
    }
    
    class func retrieveCodeVerifier() -> String? {
        return UserDefaults.standard.object(forKey: JWTUtility.codeVerifier) as? String
    }
}
