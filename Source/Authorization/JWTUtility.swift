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
    class PayloadValidatePreauthJWT: NSObject, Claims {
        var preAuthCode: String

        enum CodingKeys: String, CodingKey {
            case preAuthCode = "preauthorization_code"
        }
    }
    
    // claims to request a authorization code
    class PayloadRequestAuthJWT: NSObject, Claims {
        var clientId: String?
        var code: String?
        var codeVerifier: String?
        var grantType: String?
        var nonce: String?
        var redirectUrl: String?
        var timestamp: Double?

        enum CodingKeys: String, CodingKey {
            case clientId = "client_id"
            case code
            case codeVerifier = "code_verifier"
            case grantType = "grant_type"
            case nonce
            case redirectUrl = "redirect_uri"
            case timestamp
        }
    }
    
    // claims to validate authorization and refresh tokens
    class PayloadValidateAuthJWT: NSObject, Claims {
        var accessToken: String?
        var expiresTimestamp: Double?
        var refreshToken: String?
        var tokenType: String?
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case expiresTimestamp = "expires_on"
            case refreshToken = "refresh_token"
            case tokenType = "token_type"
        }
    }
    
    // claims to request data trigger
    class PayloadDataTriggerJWT: NSObject, Claims {
        var accessToken: String?
        var clientId: String?
        var nonce: String?
        var redirectUrl: String?
        var sessionKey: String?
        var timestamp: Double?

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case clientId = "client_id"
            case nonce
            case redirectUrl = "redirect_uri"
            case sessionKey = "session_key"
            case timestamp
        }
    }
    
    // claims to request OAuth token renewal
    class PayloadRefreshOAuthJWT: NSObject, Claims {
        var clientId: String?
        var grantType: String?
        var nonce: String?
        var redirectUrl: String?
        var refreshToken: String?
        var timestamp: Double?
        
        enum CodingKeys: String, CodingKey {
            case clientId = "client_id"
            case grantType = "grant_type"
            case nonce
            case redirectUrl = "redirect_uri"
            case refreshToken = "refresh_token"
            case timestamp
        }
    }
    
    class PayloadPostboxPush: NSObject, Claims {
        var accessToken: String?
        var clientId: String?
        var iv: String?
        var metadata: String?
        var nonce: String?
        var redirectUrl: String?
        var sessionKey: String?
        var symmetricalKey: String?
        var timestamp: Double?
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case clientId = "client_id"
            case iv
            case metadata
            case nonce
            case redirectUrl = "redirect_uri"
            case sessionKey = "session_key"
            case symmetricalKey = "symmetrical_key"
            case timestamp
        }
    }

    /// Creates request JWT which can be used to get a preAuthentication token
    ///
    /// - Parameters:
    ///   - appId: application identifier
    ///   - contractId: contract identifier
    ///   - privateKey: private key in base 64 format
    ///   - publicKey: public key in base 64 format
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
            redirectUri: configuration.redirectUri
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
    ///   - appId: application identifier
    ///   - contractId: contract identifier
    ///   - privateKey: private key in base 64 format
    ///   - publicKey: public key in base 64 format
    class func signedAuthJwt(_ authCode: String, appId: String, contractId: String, privateKey: String, publicKey: String?) -> String? {
        guard
            privateKey.isBase64(),
            let privateKeyData = convertKeyString(privateKey) else {
                print("DigiMeSDK: Error creating RSA key")
                return nil
        }

        let claims = PayloadRequestAuthJWT()
        claims.clientId = "\(appId)_\(contractId)"
        claims.code = authCode
        claims.codeVerifier = retrieveCodeVerifier()
        claims.grantType = "authorization_code"
        claims.nonce = generateNonce()
        
        // NB! this redirect schema must exist in the CA contract definition, otherwise preauth request will fail!
        claims.redirectUrl = "digime-ca-\(appId)"
        claims.timestamp = NSDate().timeIntervalSince1970 * 1000.0

        // signing
        var jwt = JWT(header: header, claims: claims)
        let signer = JWTSigner.ps512(privateKey: privateKeyData)
        guard let signedJwt = try? jwt.sign(using: signer) else {
            print("DigiMeSDK: Error signing auth JWT")
            return nil
        }

        // validation
        guard
            let publicKeyBase64 = publicKey,
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
    
    /// Extracts access and refresh tokens from JWT, and wraps in `DMEOAuthToken`.
    /// - Parameters
    ///  - jwt: JSON Web Token containing access/refresh token pair.
    ///  - publicKey: public key in base 64 format
    class func oAuthToken(from jwt: String, publicKey: String) -> OAuthToken? {
        guard let publicKeyData = convertKeyString(publicKey) else {
                print("DigiMeSDK: Error creating RSA public key")
                return nil
        }
        
        // validation
        let verifier = JWTVerifier.ps512(publicKey: publicKeyData)
        let isVerified = JWT<PayloadValidateAuthJWT>.verify(jwt, using: verifier)
        
        guard isVerified else {
            return nil
        }
        
        let decoder = JWTDecoder(jwtVerifier: verifier)
        let jwt = try? decoder.decode(JWT<PayloadValidateAuthJWT>.self, fromString: jwt)
        guard
            let accessToken = jwt?.claims.accessToken,
            let refreshToken = jwt?.claims.refreshToken,
            let expiresTimestamp = jwt?.claims.expiresTimestamp else {
            return nil
        }
        
        return OAuthToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiry: Date(timeIntervalSince1970: expiresTimestamp),
            tokenType: jwt?.claims.tokenType
        )
    }
    
    /// Creates request JWT which can be used to trigger data
    /// - Parameters:
    ///   - accessToken: OAuth access token
    ///   - appId: application identifier
    ///   - contractId: contract identifier
    ///   - sessionKey: session key
    ///   - privateKey: private key in base 64 format
    ///   - publicKey: public key in base 64 format
    class func dataTriggerJwt(_ accessToken: String, appId: String, contractId: String, sessionKey: String, privateKey: String, publicKey: String?) -> String? {
        guard
            privateKey.isBase64(),
            let privateKeyData = convertKeyString(privateKey) else {
                print("DigiMeSDK: Error creating RSA key")
                return nil
        }
        
        let claims = PayloadDataTriggerJWT()
        claims.accessToken = accessToken
        claims.clientId = "\(appId)_\(contractId)"
        claims.nonce = generateNonce()
        
        // NB! this redirect schema must exist in the CA contract definition, otherwise this request will fail!
        claims.redirectUrl = "digime-ca-\(appId)"
        claims.sessionKey = sessionKey
        claims.timestamp = NSDate().timeIntervalSince1970 * 1000.0

        // signing
        var jwt = JWT(header: header, claims: claims)
        let signer = JWTSigner.ps512(privateKey: privateKeyData)
        guard let signedJwt = try? jwt.sign(using: signer) else {
            print("DigiMeSDK: Error signing data trigger JWT")
            return nil
        }

        // validation
        guard
            let publicKeyBase64 = publicKey,
            let publicKeyData = convertKeyString(publicKeyBase64) else {
                return signedJwt
        }
        
        let verifier = JWTVerifier.ps512(publicKey: publicKeyData)
        let isVerified = JWT<PayloadDataTriggerJWT>.verify(signedJwt, using: verifier)

        return isVerified ? signedJwt : nil
    }
    
    class func refreshJwt(from refreshToken: String, appId: String, contractId: String, privateKey: String, publicKey: String?) -> String? {
        guard
            privateKey.isBase64(),
            let privateKeyData = convertKeyString(privateKey) else {
                print("DigiMeSDK: Error creating RSA key")
                return nil
        }
        
        let claims = PayloadRefreshOAuthJWT()
        claims.clientId = "\(appId)_\(contractId)"
        claims.grantType = "refresh_token"
        claims.nonce = generateNonce()
        
        // NB! this redirect schema must exist in the CA contract definition, otherwise preauth request will fail!
        claims.redirectUrl = "digime-ca-\(appId)"
        claims.refreshToken = refreshToken
        claims.timestamp = NSDate().timeIntervalSince1970 * 1000.0

        // signing
        var jwt = JWT(header: header, claims: claims)
        let signer = JWTSigner.ps512(privateKey: privateKeyData)
        guard let signedJwt = try? jwt.sign(using: signer) else {
            print("DigiMeSDK: Error signing our test token")
            return nil
        }

        // validation
        guard
            let publicKeyBase64 = publicKey,
            let publicKeyData = convertKeyString(publicKeyBase64) else {
                return signedJwt
        }
        
        let verifier = JWTVerifier.ps512(publicKey: publicKeyData)
        let isVerified = JWT<PayloadRefreshOAuthJWT>.verify(signedJwt, using: verifier)

        return isVerified ? signedJwt : nil
    }
    
//    class func postboxPushJwt(from accessToken: String?, appId: String, contractId: String, iv: String, metadata: String, sessionKey: String, symmetricalKey: String, privateKey: String, publicKey: String?) -> String? {
//        guard
//            privateKey.isBase64(),
//            let privateKeyData = convertKeyString(privateKey) else {
//                print("DigiMeSDK: Error creating RSA key")
//                return nil
//        }
//
//        let claims = PayloadPostboxPush()
//        claims.accessToken = accessToken
//        claims.clientId = "\(appId)_\(contractId)"
//        claims.iv = iv
//        claims.metadata = metadata.replacingOccurrences(of: "[\\n\\r]", with: "", options: .regularExpression, range: nil)
//        claims.nonce = generateNonce()
//
//        // NB! this redirect schema must exist in the CA contract definition, otherwise preauth request will fail!
//        claims.redirectUrl = "digime-ca-\(appId)"
//        claims.sessionKey = sessionKey
//        claims.symmetricalKey = symmetricalKey.replacingOccurrences(of: "[\\n\\r]", with: "", options: .regularExpression, range: nil)
//        claims.timestamp = NSDate().timeIntervalSince1970 * 1000.0
//
//        // signing
//        var jwt = JWT(header: header, claims: claims)
//        let signer = JWTSigner.ps512(privateKey: privateKeyData)
//        guard let signedJwt = try? jwt.sign(using: signer) else {
//            print("DigiMeSDK: Error signing our test token")
//            return nil
//        }
//
//        // validation
//        guard
//            let publicKeyBase64 = publicKey,
//            let publicKeyData = convertKeyString(publicKeyBase64) else {
//                return signedJwt
//        }
//
//        let verifier = JWTVerifier.ps512(publicKey: publicKeyData)
//        let isVerified = JWT<PayloadRefreshOAuthJWT>.verify(signedJwt, using: verifier)
//
//        return isVerified ? signedJwt : nil
//    }
    
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
