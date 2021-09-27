//
//  JWT.swift
//  DigiMeSDK
//
//  Created on 22/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation
import Security

/// JWT using RSA-PSS 512 bits algorithm. Requires RSA keys to be at least 2048 bits in length
struct JWT<T: JWTClaims>: Codable {
    
    var header: JWTHeader
    var claims: T
    
    init(claims: T) {
        self.header = JWTHeader(alg: "PS512")
        self.claims = claims
    }
    
    init(jwtString: String, keySet: JSONWebKeySet) throws {
        let components = jwtString.components(separatedBy: ".")
        guard
            components.count == 3,
            let headerData = Data(base64URLEncoded: components[0]),
            let claimsData = Data(base64URLEncoded: components[1]),
            let signature = Data(base64URLEncoded: components[2]) else {
            throw JWTError.invalidJWTString
        }
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .secondsSince1970
        let header = try headerData.decoded(dateDecodingStrategy: .secondsSince1970) as JWTHeader
        let claims = try claimsData.decoded(dateDecodingStrategy: .secondsSince1970) as T
        
        // Verify
        guard
            header.alg == "PS512",
            let kid = header.kid,
            let key = keySet.keys.first(where: { $0.kid == kid }),
            let key = try? Crypto.base64EncodedData(from: key.pem),
            let jwtData = (components[0] + "." + components[1]).data(using: .utf8) else {
            throw JWTError.failedVerification
        }
        
        let verified = try Self.verify(signature: signature, for: jwtData, using: key)
        guard verified else {
            throw JWTError.failedVerification
        }
        
        self.header = header
        self.claims = claims
    }
    
    func sign(using privateKey: Data) throws -> String {
        let headerString = try header.encode()
        let claimsString = try claims.encode()
        let unsignedJWT = headerString + "." + claimsString
        guard let unsignedData = unsignedJWT.data(using: .utf8) else {
            throw JWTError.invalidJWTString
        }
        
        let signature = try sign(data: unsignedData, using: privateKey)
        let signatureString = signature.base64URLEncodedString()
        return unsignedJWT + "." + signatureString
    }
    
    private func sign(data: Data, using privateKey: Data) throws -> Data {
        var response: Unmanaged<CFError>?
        
        let secKey = try Crypto.secKey(keyData: privateKey, isPublic: false)
        guard let signedData = SecKeyCreateSignature(secKey, .rsaSignatureMessagePSSSHA512, data as CFData, &response) else {
            
            if let error = response?.takeRetainedValue() {
                Logger.error("JWT signing failed with error: \(error)")
            }
            else {
                Logger.error("JWT signing failed with undetermined error")
            }
            
            throw JWTError.invalidPrivateKey
        }
        
        return signedData as Data
    }
    
    private static func verify(signature: Data, for data: Data, using publicKey: Data) throws -> Bool {
        var response: Unmanaged<CFError>?
        
        let secKey = try Crypto.secKey(keyData: publicKey, isPublic: true)
        let result = SecKeyVerifySignature(secKey, .rsaSignatureMessagePSSSHA512, data as CFData, signature as CFData, &response)
        
        if let response = response {
            Logger.error("JWT signature verfication failed with error: \(response.takeRetainedValue())")
            throw JWTError.failedVerification
        }
        
        return result
    }
}
