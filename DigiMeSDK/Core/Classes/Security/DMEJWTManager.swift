//
//  DMEJWTManager.swift
//  DigiMeSDK
//
//  Created on 04/12/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

import CryptorRSA
import Foundation
import SwiftJWT

@objcMembers
public class DMEJWTManager: NSObject {
    var header: Header!

    // claims to request a pre- authorization code
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
    
    // claims to validate pre- authorization code
    class PayloadValidatePreauthJWT: NSObject, Decodable, Claims {
        var preauthorizationCode: String?

        enum CodingKeys: String, CodingKey {
            case preauthorizationCode = "preauthorization_code"
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
    
    public override init() {
        super.init()
        
        // header we use everytime we create our JWT. The second `alg` parameter will be created automatically by this library, we can't define it manually
        header = Header(typ: "JWT",
                         jku: nil,
                         jwk: nil,
                         kid: nil,
                         x5u: nil,
                         x5c: nil,
                         x5t: nil,
                         x5tS256: nil,
                         cty: nil,
                         crit: nil)
    }

    // we are creating our own `request` JWT to be able to get preauthentication token wrapped in server side created JWT
    @objc public func createAndSignPreAuthToken(_ appId: String, contractId: String, publicKeyBase64: String, privateKeyBase64: String) -> String? {
        
        let randomBytes = DMECryptoUtilities.getRandomBytes(withLength: 32)
        let codeVerifierBase64Url = randomBytes.base64URLEncodedString()
        let codeChallenge = (codeVerifierBase64Url.data(using: String.Encoding.utf8)! as NSData).hashSha256().base64URLEncodedString()
        saveCodeVerifier(codeVerifierBase64Url)
        
        let claims = PayloadRequestPreauthJWT()
        claims.clientId = "\(appId)_\(contractId)"
        claims.codeChallenge = codeChallenge
        claims.nonce = (DMECryptoUtilities.getRandomBytes(withLength: 16) as NSData).hexString()
        claims.codeChallengeMethod = "S256"
        // NB! this redirect schema must exist in the CA contract definition, otherwise preauth request will fail!
        claims.redirectUrl = "digime-ca-\(appId)"
        claims.responseMode = "query"
        claims.responseType = "code"
        claims.state = (DMECryptoUtilities.getRandomBytes(withLength: 32) as NSData).hexString()
        claims.timestamp = NSDate().timeIntervalSince1970 * 1000.0

        guard
            let publicKey = convertKeyString(publicKeyBase64),
            let privateKey = convertKeyString(privateKeyBase64) else {
                print("Error creating RSA key")
            return nil
        }

        // signing
        var jwt = JWT(header: header, claims: claims)
        let signer = JWTSigner.ps512(privateKey: privateKey)
        guard let signedToken = try? jwt.sign(using: signer) else {
            print("Error signing our test token")
            return nil
        }

        // validation
        let verifier = JWTVerifier.ps512(publicKey: publicKey)
        let isVerified = JWT<PayloadRequestPreauthJWT>.verify(signedToken, using: verifier)

        return isVerified ? signedToken : nil
    }
    
    // we are creating our own `request` JWT to be able to get preauthentication token wrapped in server side created JWT
    @objc public func createAndSignAuthToken(_ authCode:String, appId: String, contractId: String, publicKeyBase64: String, privateKeyBase64: String) -> String? {
    
        let claims = PayloadRequestAuthJWT()
        claims.clientId = "\(appId)_\(contractId)"
        claims.code = authCode
        claims.codeVerifier = retrieveCodeVerifier()
        claims.grantType = "authorization_code"
        claims.nonce = (DMECryptoUtilities.getRandomBytes(withLength: 16) as NSData).hexString()
        // NB! this redirect schema must exist in the CA contract definition, otherwise preauth request will fail!
        claims.redirectUrl = "digime-ca-\(appId)"
        claims.timestamp = NSDate().timeIntervalSince1970 * 1000.0

        guard
            let publicKey = convertKeyString(publicKeyBase64),
            let privateKey = convertKeyString(privateKeyBase64) else {
                print("Error creating RSA key")
            return nil
        }

        // signing
        var jwt = JWT(header: header, claims: claims)
        let signer = JWTSigner.ps512(privateKey: privateKey)
        guard let signedToken = try? jwt.sign(using: signer) else {
            print("Error signing our test token")
            return nil
        }

        // validation
        let verifier = JWTVerifier.ps512(publicKey: publicKey)
        let isVerified = JWT<PayloadRequestAuthJWT>.verify(signedToken, using: verifier)

        return isVerified ? signedToken : nil
    }
    
    // we receive JWT that we need to validate and extract the pre-auth token that will be later forwarded to digi.me client to obtain authorization code
    @objc public func validateAndExtractPreauthCode(_ publicKeyBase64: String, preauthToken: String) -> String? {
        guard let publicKey = convertKeyString(publicKeyBase64) else {
            print("Error creating RSA public key")
            return nil
        }
        
        // validation
        let verifier = JWTVerifier.ps512(publicKey: publicKey)
        let isVerified = JWT<PayloadValidatePreauthJWT>.verify(preauthToken, using: verifier)
        
        guard isVerified else {
            return nil
        }
        
        let decoder = JWTDecoder(jwtVerifier: verifier)
        let jwt = try? decoder.decode(JWT<PayloadValidatePreauthJWT>.self, fromString: preauthToken)
        guard let preauthCode = jwt?.claims.preauthorizationCode else {
            return nil
        }
        saveAuthorityPublicKey(publicKeyBase64, creationDate: Date())
        return preauthCode
    }
    
    @objc public func validateAndDecodeCyclicCAAuthAndRefreshTokensFromJWT(_ authToken: String) -> DMEOAuthObject? {
        guard
            let publicKeyBase64 = retrieveAuthorityPublicKeyIfValid(),
            let publicKey = convertKeyString(publicKeyBase64) else {
            print("Error creating RSA public key")
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
        
        let oauthObj = DMEOAuthObject()
        oauthObj.accessToken = accessToken
        oauthObj.refreshToken = refreshToken
        oauthObj.expiresOn = Date(timeIntervalSince1970: expiresTimestamp)
        
        return oauthObj
    }
    
    // MARK: - Utility functions
    private func convertKeyString(_ keyString: String) -> Data? {
        guard let base64String = try? CryptorRSA.base64String(for: keyString) else {
            print("Couldn't read a key string")
            return nil
        }

        return convertKeyBase64ToData(base64String)
    }
    
    private func convertKeyBase64ToData(_ base64KeyString: String) -> Data? {
        guard let publicKeyData = Data(base64Encoded: base64KeyString, options: [.ignoreUnknownCharacters]) else {
            print("Couldn't decode base64 key")
            return nil
        }

        return publicKeyData
    }
}

// MARK: - Utility extensions

extension DMEJWTManager {
    static let authorityPublicKey: String = "authorityPublicKey"
    static let codeVerifier: String = "codeVerifier"
    
    struct AuthorityPublicKey: Codable {
        var publicKeyBase64: String
        var creationDate: Date
    }
    
    // we need to save Authority public key in the case if app will be restarted
    func saveAuthorityPublicKey(_ publicKeyBase64: String, creationDate: Date) {
        let data = AuthorityPublicKey(publicKeyBase64: publicKeyBase64, creationDate: creationDate)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: DMEJWTManager.authorityPublicKey)
        }
    }
    
    // we only reuse stored authority public key if it was stored less than 15 mins ago
    func retrieveAuthorityPublicKeyIfValid() -> String? {
        if let data = UserDefaults.standard.object(forKey: DMEJWTManager.authorityPublicKey) as? Data {
            if
                let decoded = try? JSONDecoder().decode(AuthorityPublicKey.self, from: data),
                let diff = Calendar.current.dateComponents([.minute], from: decoded.creationDate, to: Date()).minute,
                diff < 15 {
                    return decoded.publicKeyBase64
            }
        }
        
        return nil
    }
    
    // save code verifier for OAuth session
    func saveCodeVerifier(_ codeVerifier: String) {
        let defaults = UserDefaults.standard
        defaults.set(codeVerifier, forKey: DMEJWTManager.codeVerifier)
    }
    
    func retrieveCodeVerifier() -> String? {
        return UserDefaults.standard.object(forKey: DMEJWTManager.codeVerifier) as? String
    }
}

extension Data {
    init?(base64URLEncoded string: String) {
        self.init(base64Encoded: string.convertToBase64())
    }

    func base64URLEncodedString() -> String {
        return self.base64EncodedString().convertToBase64URL()
    }
}

extension String {
    func convertToBase64() -> String {
        var base64 = self.replacingOccurrences(of: "_", with: "/").replacingOccurrences(of: "-", with: "+")
        if base64.count % 4 != 0 {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }
        return base64
    }

    func convertToBase64URL() -> String {
        let base64url = self.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "=", with: "")
        return base64url
    }
}
