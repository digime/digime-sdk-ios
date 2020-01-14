//
//  DMEJWTUtility.swift
//  DigiMeSDK
//
//  Created on 04/12/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

import CryptorRSA
import Foundation
import SwiftJWT

@objcMembers
public class DMEJWTUtility: NSObject {
   
    // Default JWT header
    static var header = Header(typ: "JWT",
                               jku: nil,
                               jwk: nil,
                               kid: nil,
                               x5u: nil,
                               x5c: nil,
                               x5t: nil,
                               x5tS256: nil,
                               cty: nil,
                               crit: nil)

    // claims to request a pre-authorization code
    class PayloadRequestPreauthJWT: NSObject, Decodable, Claims {
        var clientId: String?
        var codeChallenge: String?
        var codeChallengeMethod: String?
        var nonce: String?
        var redirectUrl: String?
        var responseMode: String?
        var responseType: String?
        var state: String?
        var timestamp: Double?

        enum CodingKeys: String, CodingKey {
            case clientId = "client_id"
            case codeChallenge = "code_challenge"
            case codeChallengeMethod = "code_challenge_method"
            case nonce
            case redirectUrl = "redirect_uri"
            case responseMode = "response_mode"
            case responseType =  "response_type"
            case state
            case timestamp
        }
    }
    
    // claims to validate pre-authorization code
    class PayloadValidatePreauthJWT: NSObject, Decodable, Claims {
        var preAuthCode: String?

        enum CodingKeys: String, CodingKey {
            case preAuthCode = "preauthorization_code"
        }
    }
    
    // claims to request a authorization code
    class PayloadRequestAuthJWT: NSObject, Decodable, Claims {
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
    class PayloadValidateAuthJWT: NSObject, Decodable, Claims {
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
    class PayloadDataTriggerJWT: NSObject, Decodable, Claims {
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
    class PayloadRefreshOAuthJWT: NSObject, Decodable, Claims {
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

    /// Creates request JWT which can be used to get a preAuthentication token
    ///
    /// - Parameters:
    ///   - appId: application identifier
    ///   - contractId: contract identifier
    ///   - privateKey: private key in base 64 format
    ///   - publicKey: public key in base 64 format
    @objc public class func signedPreAuthJwt(_ appId: String, contractId: String, privateKey: String, publicKey: String?) -> String? {
        guard
            privateKey.isHex(),
            let privateKeyData = convertKeyString(privateKey) else {
                print("DigiMeSDK: Error creating RSA key")
                return nil
        }
        
        let randomBytes = DMECryptoUtilities.randomBytes(withLength: 32)
        let codeVerifierBase64Url = randomBytes.base64URLEncodedString()
        let codeChallenge = (codeVerifierBase64Url.data(using: String.Encoding.utf8)! as NSData).hashSha256().base64URLEncodedString()
        saveCodeVerifier(codeVerifierBase64Url)
        
        let claims = PayloadRequestPreauthJWT()
        claims.clientId = "\(appId)_\(contractId)"
        claims.codeChallenge = codeChallenge
        claims.nonce = (DMECryptoUtilities.randomBytes(withLength: 16) as NSData).hexString()
        claims.codeChallengeMethod = "S256"
        
        // NB! this redirect schema must exist in the CA contract definition, otherwise preauth request will fail!
        claims.redirectUrl = "digime-ca-\(appId)"
        claims.responseMode = "query"
        claims.responseType = "code"
        claims.state = (DMECryptoUtilities.randomBytes(withLength: 32) as NSData).hexString()
        claims.timestamp = NSDate().timeIntervalSince1970 * 1000.0

        // signing
        var jwt = JWT(header: header, claims: claims)
        let signer = JWTSigner.ps512(privateKey: privateKeyData)
        guard let signedJwt = try? jwt.sign(using: signer) else {
            print("DigiMeSDK: Error signing preAuth JWT")
            return nil
        }

        // validation
        guard
            let publicKeyBase64 = publicKey,
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
    @objc public class func signedAuthJwt(_ authCode: String, appId: String, contractId: String, privateKey: String, publicKey: String?) -> String? {
        guard
            privateKey.isHex(),
            let privateKeyData = convertKeyString(privateKey) else {
                print("DigiMeSDK: Error creating RSA key")
                return nil
        }

        let claims = PayloadRequestAuthJWT()
        claims.clientId = "\(appId)_\(contractId)"
        claims.code = authCode
        claims.codeVerifier = retrieveCodeVerifier()
        claims.grantType = "authorization_code"
        claims.nonce = (DMECryptoUtilities.randomBytes(withLength: 16) as NSData).hexString()
        
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
    ///   - publicKey: public key in base 64 format
    ///   - jwt: pre-authorization code wrapped in JWT
    @objc public class func preAuthCode(from jwt: String, publicKey: String) -> String? {
        guard
            publicKey.isHex(),
            let publicKeyData = convertKeyString(publicKey) else {
                print("DigiMeSDK: Error creating RSA public key")
                return nil
        }
        
        // validation
        let verifier = JWTVerifier.ps512(publicKey: publicKeyData)
        let isVerified = JWT<PayloadValidatePreauthJWT>.verify(jwt, using: verifier)
        
        guard isVerified else {
            return nil
        }
        
        let decoder = JWTDecoder(jwtVerifier: verifier)
        let decodedJwt = try? decoder.decode(JWT<PayloadValidatePreauthJWT>.self, fromString: jwt)
        guard let preauthCode = decodedJwt?.claims.preAuthCode else {
            return nil
        }
        return preauthCode
    }
    
    @objc public class func validateAndDecodeOngoingAccessAuthAndRefreshTokensFromJWT(_ authToken: String, authorityPublicKey: String) -> DMEOAuthToken? {
        guard let publicKey = convertKeyString(authorityPublicKey) else {
                print("DigiMeSDK: Error creating RSA public key")
                return nil
        }
        
        // validation
        let verifier = JWTVerifier.ps512(publicKey: publicKey)
        let isVerified = JWT<PayloadValidateAuthJWT>.verify(authToken, using: verifier)
        
        guard isVerified else {
            return nil
        }
        
        let decoder = JWTDecoder(jwtVerifier: verifier)
        let jwt = try? decoder.decode(JWT<PayloadValidateAuthJWT>.self, fromString: authToken)
        guard
            let accessToken = jwt?.claims.accessToken,
            let refreshToken = jwt?.claims.refreshToken,
            let expiresTimestamp = jwt?.claims.expiresTimestamp else {
            return nil
        }
        
        let oAuthToken = DMEOAuthToken()
        oAuthToken.accessToken = accessToken
        oAuthToken.refreshToken = refreshToken
        oAuthToken.expiresOn = Date(timeIntervalSince1970: expiresTimestamp)
        
        return oAuthToken
    }
    
    /// Creates request JWT which can be used to trigger data
    /// - Parameters:
    ///   - accessToken: OAuth access token
    ///   - appId: application identifier
    ///   - contractId: contract identifier
    ///   - sessionKey: session key
    ///   - privateKey: private key in base 64 format
    ///   - publicKey: public key in base 64 format
    @objc public class func dataTriggerJwt(_ accessToken: String, appId: String, contractId: String, sessionKey: String, privateKey: String, publicKey: String?) -> String? {
        guard
            privateKey.isHex(),
            let privateKeyData = convertKeyString(privateKey) else {
                print("DigiMeSDK: Error creating RSA key")
                return nil
        }
        
        let claims = PayloadDataTriggerJWT()
        claims.accessToken = accessToken
        claims.clientId = "\(appId)_\(contractId)"
        claims.nonce = (DMECryptoUtilities.randomBytes(withLength: 16) as NSData).hexString()
        
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
    
    @objc public class func refreshJwt(from refreshToken: String, appId: String, contractId: String, privateKey: String, publicKey: String?) -> String? {
        let claims = PayloadRefreshOAuthJWT()
        claims.clientId = "\(appId)_\(contractId)"
        claims.grantType = "refresh_token"
        claims.nonce = (DMECryptoUtilities.randomBytes(withLength: 16) as NSData).hexString()
        
        // NB! this redirect schema must exist in the CA contract definition, otherwise preauth request will fail!
        claims.redirectUrl = "digime-ca-\(appId)"
        claims.refreshToken = refreshToken
        claims.timestamp = NSDate().timeIntervalSince1970 * 1000.0
        
        guard
            privateKey.isHex(),
            let privateKeyData = convertKeyString(privateKey) else {
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
            let publicKeyBase64 = publicKey,
            let publicKeyData = convertKeyString(publicKeyBase64) else {
                return signedJwt
        }
        
        let verifier = JWTVerifier.ps512(publicKey: publicKeyData)
        let isVerified = JWT<PayloadRefreshOAuthJWT>.verify(signedJwt, using: verifier)

        return isVerified ? signedJwt : nil
    }
    
    // MARK: - Utility functions
    private class func convertKeyString(_ keyString: String) -> Data? {
        guard let base64String = try? CryptorRSA.base64String(for: keyString) else {
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
}

// MARK: - Utility extensions

extension DMEJWTUtility {
    static let codeVerifier: String = "codeVerifier"
    
    // save code verifier for OAuth session
    class func saveCodeVerifier(_ codeVerifier: String) {
        let defaults = UserDefaults.standard
        defaults.set(codeVerifier, forKey: DMEJWTUtility.codeVerifier)
    }
    
    class func retrieveCodeVerifier() -> String? {
        return UserDefaults.standard.object(forKey: DMEJWTUtility.codeVerifier) as? String
    }
}
