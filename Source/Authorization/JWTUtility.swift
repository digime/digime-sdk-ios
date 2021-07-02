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

protocol RequestClaims: Claims {
}

extension RequestClaims {
    func encode() throws -> String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .millisecondsSince1970
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try jsonEncoder.encode(self)
        return JWTEncoder.base64urlEncodedString(data: data)
    }
}

class JWTUtility: NSObject {
   
    // Default JWT header
    class var header: Header {
        Header(typ: "JWT")
    }

    // Claims to request a pre-authorization code
    private struct PayloadRequestPreauthJWT: RequestClaims {
        let accessToken: String?
        let clientId: String
        let codeChallenge: String
        var codeChallengeMethod = "S256"
        var nonce = JWTUtility.generateNonce()
        let redirectUri: String
        var responseMode = "query"
        var responseType = "code"
        var state = JWTUtility.secureRandomHexString(length: 32)
        var timestamp = Date()
    }
    
    // Claims for pre-authorization code response
    private struct PayloadResponsePreauthJWT: Claims {
        var preAuthCode: String

        enum CodingKeys: String, CodingKey {
            case preAuthCode = "preauthorization_code"
        }
    }
    
    // Claims to request a authorization code
    private struct PayloadRequestAuthJWT: RequestClaims {
        let clientId: String
        let code: String
        let codeVerifier: String
        var grantType = "authorization_code"
        var nonce = JWTUtility.generateNonce()
        let redirectUri: String
        var timestamp = Date()
    }
    
    // Claims to request data trigger. Also used for requesting reference token and deleting user
    private struct PayloadDataTriggerJWT: RequestClaims {
        let accessToken: String
        let clientId: String
        var nonce = JWTUtility.generateNonce()
        let redirectUri: String
        var timestamp = Date()
    }
    
    // Claims to request OAuth token renewal
    private struct PayloadRefreshOAuthJWT: RequestClaims {
        let clientId: String
        var grantType = "refresh_token"
        var nonce = JWTUtility.generateNonce()
        let redirectUri: String
        let refreshToken: String
        var timestamp = Date()
    }
    
    // Claims to request writing data
    private struct PayloadWriteJWT: RequestClaims {
        let accessToken: String
        let clientId: String
        let iv: String
        let metadata: String
        var nonce = JWTUtility.generateNonce()
        let redirectUri: String
        let symmetricalKey: String
        var timestamp = Date()
    }

    /// Creates request JWT which can be used to get a pre-authentication token
    ///
    /// If a contract has already been linked to a library and both its access and refersh tokens have expired, then passing the expired access token will reauthorize access to the library
    ///
    /// If one contract has been linked to a library and another contract wants to be linked to the same library, then pass the access token for the contract which is already linked
    ///
    /// - Parameters:
    ///   - configuration: this SDK's instance configuration
    ///   - accessToken: An existing access token
    class func preAuthorizationRequestJWT(configuration: Configuration, accessToken: String? = nil) -> String? {
        let randomBytes = secureRandomData(length: 32)
        let codeVerifier = randomBytes.base64URLEncodedString()
        let codeChallenge = Data(SHA256.hash(data: codeVerifier.data(using: .utf8)!)).base64URLEncodedString()
        saveCodeVerifier(codeVerifier)
        
        let claims = PayloadRequestPreauthJWT(
            accessToken: accessToken,
            clientId: configuration.clientId,
            codeChallenge: codeChallenge,
            
            // NB! this redirect schema must exist in the contract definition, otherwise preauth request will fail!
            redirectUri: configuration.redirectUri + "auth"
        )
        
        return createRequestJWT(claims: claims, configuration: configuration)
    }
    
    /// Creates request JWT which can be used to get an authentication token
    ///
    /// - Parameters:
    ///   - authCode: OAuth authorization code
    ///   - configuration: this SDK's instance configuration
    class func authorizationRequestJWT(authCode: String, configuration: Configuration) -> String? {
        let claims = PayloadRequestAuthJWT(
            clientId: configuration.clientId,
            code: authCode,
            codeVerifier: retrieveCodeVerifier()!,
            
            // NB! this redirect schema must exist in the contract definition, otherwise preauth request will fail!
            redirectUri: configuration.redirectUri + "auth"
        )
        
        return createRequestJWT(claims: claims, configuration: configuration)
    }
    
    /// Extracts preAuthorization code from JWT
    ///
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
            let decodedJwt = try decoder.decode(JWT<PayloadResponsePreauthJWT>.self, fromString: jwt)
            return decodedJwt.claims.preAuthCode
        }
    }
    
    /// Extracts access and refresh tokens from JWT, and wraps in `OAuthToken`.
    ///
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
    ///
    /// - Parameters:
    ///   - accessToken: OAuth access token
    ///   - configuration: this SDK's instance configuration
    class func dataTriggerRequestJWT(accessToken: String, configuration: Configuration) -> String? {
        let claims = PayloadDataTriggerJWT(
            accessToken: accessToken,
            clientId: configuration.clientId,
            redirectUri: configuration.redirectUri + "auth"
        )
        
        return createRequestJWT(claims: claims, configuration: configuration)
    }
    
    /// Creates request JWT which can be used to refresh oauth tokens
    ///
    /// - Parameters:
    ///   - refreshToken: OAuth refresh token
    ///   - configuration: this SDK's instance configuration
    class func refreshTokensRequestJWT(refreshToken: String, configuration: Configuration) -> String? {
        let claims = PayloadRefreshOAuthJWT(
            clientId: configuration.clientId,
            redirectUri: configuration.redirectUri + "auth",
            refreshToken: refreshToken
        )
        
        return createRequestJWT(claims: claims, configuration: configuration)
    }
    
    /// Creates request JWT which can be used to write data
    ///
    /// - Parameters:
    ///   - accessToken: OAuth refresh token
    ///   - iv: iv used to encrypt data
    ///   - metadat: metadata describing data being pushed
    ///   - symmetricKey: symmetrical key used to encrypt data
    ///   - configuration: this SDK's instance configuration
    class func writeRequestJWT(accessToken: String, iv: Data, metadata: String, symmetricKey: String, configuration: Configuration) -> String? {
        let claims = PayloadWriteJWT(
            accessToken: accessToken,
            clientId: configuration.clientId,
            iv: iv.hexString,
            metadata: metadata,
            redirectUri: configuration.redirectUri + "auth",
            symmetricalKey: symmetricKey
        )

        return createRequestJWT(claims: claims, configuration: configuration)
    }
    
    // MARK: - Utility functions
    private class func createRequestJWT<T: RequestClaims>(claims: T, configuration: Configuration) -> String? {
        guard let privateKeyData = convertKeyString(configuration.privateKey) else {
            print("DigiMeSDK: Error creating RSA key")
            return nil
        }

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
    
    private class func generateNonce() -> String {
        secureRandomHexString(length: 16)
    }
    
    private class func secureRandomHexString(length: Int) -> String {
        secureRandomBytes(length: length).hexString
    }
    
    private class func secureRandomData(length: Int) -> Data {
        Data(secureRandomBytes(length: length))
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
    
    /// Get the Base64 representation of a PEM encoded string after stripping off the PEM markers.
    ///
    /// - Parameters:
    ///   - pemString: `String` containing PEM formatted data.
    /// - Returns: Base64 encoded `String` containing the data.
    private class func base64String(for pemString: String) -> String? {
        // Filter looking for new lines...
        let lines = pemString
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
