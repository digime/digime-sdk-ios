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
		let data = try self.encoded(dateEncodingStrategy: .millisecondsSince1970)
        return data.base64URLEncodedString()
    }
}

enum JWTUtility {
	private struct PayloadRequestLogsUploadJWT: RequestClaims {
		let clientId: String
		var nonce = JWTUtility.generateNonce()
		var timestamp = Date()
		
		enum CodingKeys: String, CodingKey {
			case clientId = "client_id"
			case nonce
			case timestamp
		}
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
		
		enum CodingKeys: String, CodingKey {
			case accessToken = "access_token"
			case clientId = "client_id"
			case codeChallenge = "code_challenge"
			case codeChallengeMethod = "code_challenge_method"
			case nonce
			case redirectUri = "redirect_uri"
			case responseMode = "response_mode"
			case responseType = "response_type"
			case state
			case timestamp
		}
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
        var timestamp = Date()
		
		enum CodingKeys: String, CodingKey {
			case clientId = "client_id"
			case code
			case codeVerifier = "code_verifier"
			case grantType = "grant_type"
			case nonce
			case timestamp
		}
    }
    
    // Claims to request data trigger. Also used for requesting reference token and deleting user
    private struct PayloadDataTriggerJWT: RequestClaims {
        let accessToken: String
        let clientId: String
        var nonce = JWTUtility.generateNonce()
        var timestamp = Date()
		
		enum CodingKeys: String, CodingKey {
			case accessToken = "access_token"
			case clientId = "client_id"
			case nonce
			case timestamp
		}
    }
    
    // Claims to request OAuth token renewal
    private struct PayloadRefreshOAuthJWT: RequestClaims {
        let clientId: String
		var grantType = "refresh_token"
        var nonce = JWTUtility.generateNonce()
        let refreshToken: String
        var timestamp = Date()
		
		enum CodingKeys: String, CodingKey {
			case clientId = "client_id"
			case grantType = "grant_type"
			case nonce
			case refreshToken = "refresh_token"
			case timestamp
		}
    }
    
    // Claims to request writing data
    private struct PayloadWriteJWT: RequestClaims {
        let accessToken: String
        let clientId: String
        let iv: String
        let metadata: String
        var nonce = JWTUtility.generateNonce()
        let symmetricalKey: String
        var timestamp = Date()
		
		enum CodingKeys: String, CodingKey {
			case accessToken = "access_token"
			case clientId = "client_id"
			case iv
			case metadata
			case nonce
			case symmetricalKey = "symmetrical_key"
			case timestamp
		}
    }
	
	// Claims to request uploading data
	private struct PayloadFileUploadJWT: RequestClaims {
		let accessToken: String
		let clientId: String
		var nonce = JWTUtility.generateNonce()
		var timestamp = Date()
		
		enum CodingKeys: String, CodingKey {
			case accessToken = "access_token"
			case clientId = "client_id"
			case nonce
			case timestamp
		}
	}
	
	private struct PayloadDataReadJWT: RequestClaims {
		let accessToken: String
		let clientId: String
		var nonce = JWTUtility.generateNonce()
		var timestamp = Date()
		
		enum CodingKeys: String, CodingKey {
			case accessToken = "access_token"
			case clientId = "client_id"
			case nonce
			case timestamp
		}
	}
	
	private struct PayloadRequestTokenReferenceJWT: RequestClaims {
		let accessToken: String
		let clientId: String
		var nonce = JWTUtility.generateNonce()
		var timestamp = Date()
		let redirectUri: String
		
		enum CodingKeys: String, CodingKey {
			case accessToken = "access_token"
			case clientId = "client_id"
			case nonce
			case timestamp
			case redirectUri = "redirect_uri"
		}
	}
	
	// Claims to request uploading data file descriptor
	private struct PayloadFileDescriptorUploadJWT: RequestClaims {
		let metadata: RawFileMetadata
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
	
	static func logsUploadRequestJWT(configuration: Configuration) -> String? {
		let claims = PayloadRequestLogsUploadJWT(clientId: configuration.clientId)
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
            codeVerifier: retrieveCodeVerifier(configuration: configuration)!
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
        }.mapError { _ in SDKError.errorDecodedingJwtPreAuthCode }
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
        }.mapError { _ in SDKError.errorExtractingTokensFromJwt }
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
        }.mapError { _ in SDKError.errorExtractingReferenceCodeFromJwt }
    }
    
    /// Creates request JWT which can be used to trigger data
    ///
    /// - Parameters:
    ///   - accessToken: OAuth access token
    ///   - configuration: this SDK's instance configuration
    static func dataTriggerRequestJWT(accessToken: String, configuration: Configuration) -> String? {
        let claims = PayloadDataTriggerJWT(
            accessToken: accessToken,
			clientId: configuration.clientId
        )
        
        return createRequestJWT(claims: claims, configuration: configuration)
    }
    
	/// Creates request JWT which can be used to download file
	///
	/// - Parameters:
	///   - accessToken: OAuth access token
	///   - configuration: this SDK's instance configuration
	static func fileDownloadRequestJWT(accessToken: String, configuration: Configuration) -> String? {
		let claims = PayloadDataReadJWT(
			accessToken: accessToken,
			clientId: configuration.clientId
		)
		
		return createRequestJWT(claims: claims, configuration: configuration)
	}
	
	/// Creates request JWT which can be used to download file
	///
	/// - Parameters:
	///   - accessToken: OAuth access token
	///   - configuration: this SDK's instance configuration
	static func requestTokenReferenceJWT(accessToken: String, configuration: Configuration) -> String? {
		let claims = PayloadRequestTokenReferenceJWT(
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
            symmetricalKey: symmetricKey.replacingOccurrences(of: "[\\n\\r]", with: "", options: .regularExpression, range: nil)
        )

        return createRequestJWT(claims: claims, configuration: configuration)
    }
	
	/// Creates request JWT which can be used to upload file data
	///
	/// - Parameters:
	///   - accessToken: OAuth refresh token
	///   - configuration: this SDK's instance configuration
	static func fileUploadRequestJWT(accessToken: String, configuration: Configuration) -> String? {
		let claims = PayloadFileUploadJWT(
			accessToken: accessToken,
			clientId: configuration.clientId
		)
		
		return createRequestJWT(claims: claims, configuration: configuration)
	}
	
	/// Creates request JWT which can be used to upload file data descriptor
	///
	/// - Parameters:
	///   - metadata: metadata describing data being uploaded
	///   - configuration: this SDK's instance configuration
	static func fileDescriptorUploadRequestJWT(metadata: RawFileMetadata, configuration: Configuration) -> String? {
		let claims = PayloadFileDescriptorUploadJWT(
			metadata: metadata
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
