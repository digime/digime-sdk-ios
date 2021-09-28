//
//  FileUploadOperation.swift
//  DigiMeSDK
//
//  Created on 25/08/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

class FileUploadOperation: RetryingOperation {
    
    private let apiClient: APIClient
    private let data: Data
    private let metadata: Data
    private let credentials: Credentials
    private let configuration: Configuration
    
    var uploadCompletion: ((Result<Session, SDKError>) -> Void)?
    
    init(data: Data, metadata: Data, credentials: Credentials, configuration: Configuration, apiClient: APIClient) {
        self.apiClient = apiClient
        self.data = data
        self.metadata = metadata
        self.credentials = credentials
        self.configuration = configuration
    }
        
    override func main() {
        guard !isCancelled else {
            finish()
            return
        }
        
        guard let writeAccessInfo = credentials.writeAccessInfo else {
            uploadCompletion?(.failure(.incorrectContractType))
            finish()
            return
        }
        
        let symmetricKey = AES256.generateSymmetricKey()
        let iv = AES256.generateInitializationVector()
        
        do {
            let aes = try AES256(key: symmetricKey, iv: iv)
            
            let encryptedMetadata = try aes.encrypt(metadata).base64EncodedString(options: .lineLength64Characters)
            let payload = try aes.encrypt(data)
            let encryptedSymmetricKey = try Crypto.encrypt(symmetricKey: symmetricKey, publicKey: writeAccessInfo.publicKey)
            guard let jwt = JWTUtility.writeRequestJWT(accessToken: credentials.token.accessToken.value, iv: iv, metadata: encryptedMetadata, symmetricKey: encryptedSymmetricKey, configuration: configuration) else {
                throw SDKError.writeRequestFailure
            }
            
            apiClient.makeRequest(WriteDataRoute(postboxId: writeAccessInfo.postboxId, payload: payload, jwt: jwt)) { result in
                self.uploadCompletion?(result.map { $0.session })
                self.finish()
            }
        }
        catch {
            uploadCompletion?(.failure(.writeRequestFailure))
            finish()
        }
    }
    
    override func cancel() {
        uploadCompletion = nil
        super.cancel()
    }
}
