//
//  CertificateParser.swift
//  DigiMe
//
//  Created on 23/12/2020.
//  Copyright © 2020 digi.me Limited. All rights reserved.
//

import Foundation
import ASN1Decoder

struct CertificateParser {
    private enum CustomOID {
        static let contractData = "1.2.826.0.1.6861219.1"
    }
    
    init() {
    }
    
    func parse(contractResponse: ContractResponse, completion: @escaping (Result<ContractVersion5, SDKError>) -> Void) {
        guard contractResponse.type == "x509" else {
            completion(.failure(.certificateTypeIsNotSupported))
            return
        }
        
		if
			!contractResponse.certificate.isEmpty,
			let data = Data(base64Encoded: contractResponse.certificate, options: .ignoreUnknownCharacters) {
			
            completion(self.parseCertificate(data: data))
        }
        else {
            completion(.failure(.certificateEncodingDataError))
        }
    }
    
    private func parseCertificate(data: Data) -> Result<ContractVersion5, SDKError> {
        do {
            guard
                let x509 = try? X509Certificate(data: data),
                let jsonString = x509.extensionObject(oid: CustomOID.contractData)?.value as? String,
                let jsonData = jsonString.data(using: .utf8) else {
                    
                return .failure(.certificateParserInvalidData)
            }
            
            if let result = try? jsonData.decoded(dateDecodingStrategy: .millisecondsSince1970) as ContractVersion5 {
                return .success(result)
            }
            else if try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) is [String: Any] {
                return .failure(.certificateFormatIsNotSupported)
            }
            else {
                return .failure(.certificateParserInvalidData)
            }
        }
        catch {
            return .failure(.certificateParserError(error: error))
        }
    }
}
