//
//  JWTUtility.swift
//  DigiMeSDK
//
//  Created on 04/12/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

import Foundation

extension OAuthToken: JWTClaims {
}

protocol RequestClaims: JWTClaims {
}

extension RequestClaims {
    func encode() throws -> String {
        let data = try self.encoded(dateEncodingStrategy: .millisecondsSince1970, keyEncodingStrategy: .convertToSnakeCase)
        return data.base64URLEncodedString()
    }
}

enum JWTUtility {

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
    private struct PayloadResponsePreauthJWT: JWTClaims {
        let preAuthCode: String

        enum CodingKeys: String, CodingKey {
            case preAuthCode = "preauthorization_code"
        }
    }
    
    // Claims for pre-authorization code response
    private struct PayloadResponseTokenReferenceJWT: JWTClaims {
        let referenceCode: String
        let tokenType: String
        let expiry: Date

        enum CodingKeys: String, CodingKey {
            case referenceCode = "reference_code"
            case tokenType = "token_type"
            case expiry = "expires_on"
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
    static func preAuthorizationRequestJWT(configuration: Configuration, accessToken: String?) -> String? {
        let randomBytes = Crypto.secureRandomData(length: 32)
        let codeVerifier = randomBytes.base64URLEncodedString()
        let codeChallenge = Crypto.sha256Hash(from: codeVerifier).base64URLEncodedString()
        saveCodeVerifier(codeVerifier, configuration: configuration)
        
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
    static func authorizationRequestJWT(authCode: String, configuration: Configuration) -> String? {
        let claims = PayloadRequestAuthJWT(
            clientId: configuration.clientId,
            code: authCode,
            codeVerifier: retrieveCodeVerifier(configuration: configuration)!,
            
            // NB! this redirect schema must exist in the contract definition, otherwise preauth request will fail!
            redirectUri: configuration.redirectUri + "auth"
        )
        
        return createRequestJWT(claims: claims, configuration: configuration)
    }
    
    /// Extracts preAuthorization code from JWT
    ///
    /// - Parameters:
    ///   - jwt: pre-authorization code wrapped in JWT
    ///   - keySet: JSON Web Key Set
    /// - Returns: The pre-authorization code if successful or an error if not
    static func preAuthCode(from jwt: String, keySet: JSONWebKeySet) -> Result<String, SDKError> {
        return Result {
            let decodedJwt = try JWT<PayloadResponsePreauthJWT>(jwtString: jwt, keySet: keySet)
            return decodedJwt.claims.preAuthCode
        }.mapError { _ in SDKError.invalidData }
    }
    
    /// Extracts access and refresh tokens from JWT, and wraps in `OAuthToken`.
    ///
    /// - Parameters:
    ///   - jwt: JSON Web Token containing access/refresh token pair.
    ///   - keySet: JSON Web Key Set
    /// - Returns: An `OAuthToken` if successful or an error if not
    static func oAuthToken(from jwt: String, keySet: JSONWebKeySet) -> Result<OAuthToken, SDKError> {
        return Result {
            let decodedJwt = try  JWT<OAuthToken>(jwtString: jwt, keySet: keySet)
            return decodedJwt.claims
        }.mapError { _ in SDKError.invalidData }
    }
    
    /// Extracts reference code from JWT
    ///
    /// - Parameters:
    ///   - jwt: reference code wrapped in JWT
    ///   - keySet: JSON Web Key Set
    /// - Returns: The reference code if successful or an error if not
    static func referenceCode(from jwt: String, keySet: JSONWebKeySet) -> Result<String, SDKError> {
        return Result {
            let decodedJwt = try JWT<PayloadResponseTokenReferenceJWT>(jwtString: jwt, keySet: keySet)
            return decodedJwt.claims.referenceCode
        }.mapError { _ in SDKError.invalidData }
    }
    
    /// Creates request JWT which can be used to trigger data
    ///
    /// - Parameters:
    ///   - accessToken: OAuth access token
    ///   - configuration: this SDK's instance configuration
    static func dataTriggerRequestJWT(accessToken: String, configuration: Configuration) -> String? {
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
    static func refreshTokensRequestJWT(refreshToken: String, configuration: Configuration) -> String? {
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
    ///   - metadata: metadata describing data being pushed
    ///   - symmetricKey: symmetric key used to encrypt data
    ///   - configuration: this SDK's instance configuration
    static func writeRequestJWT(accessToken: String, iv: Data, metadata: String, symmetricKey: String, configuration: Configuration) -> String? {
        let claims = PayloadWriteJWT(
            accessToken: accessToken,
            clientId: configuration.clientId,
            iv: iv.hexString,
            metadata: metadata.replacingOccurrences(of: "[\\n\\r]", with: "", options: .regularExpression, range: nil),
            redirectUri: configuration.redirectUri + "auth",
            symmetricalKey: symmetricKey.replacingOccurrences(of: "[\\n\\r]", with: "", options: .regularExpression, range: nil)
        )

        return createRequestJWT(claims: claims, configuration: configuration)
    }
    
    // MARK: - Utility functions
    private static func createRequestJWT<T: RequestClaims>(claims: T, configuration: Configuration) -> String? {
        let jwt = JWT(claims: claims)
        return try? jwt.sign(using: configuration.privateKeyData)
    }
    
    private static func generateNonce() -> String {
        secureRandomHexString(length: 16)
    }
    
    private static func secureRandomHexString(length: Int) -> String {
        Crypto.secureRandomBytes(length: length).hexString
    }
}

// MARK: - Utility extensions

extension JWTUtility {
    private static let codeVerifierPrefix: String = "me.digi.sdk.codeVerifier."
    
    // save code verifier for OAuth session
    private static func saveCodeVerifier(_ codeVerifier: String, configuration: Configuration) {
        let defaults = UserDefaults.standard
        defaults.set(codeVerifier, forKey: JWTUtility.codeVerifierPrefix + configuration.contractId)
    }
    
    private static func retrieveCodeVerifier(configuration: Configuration) -> String? {
        return UserDefaults.standard.object(forKey: JWTUtility.codeVerifierPrefix + configuration.contractId) as? String
    }
}
