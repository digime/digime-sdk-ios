//
//  MultipartFormData.swift
//  DigiMeSDK
//
//  Created on 04/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

class MultipartFormData {
    enum EncodingCharacters {
        static let crlf = "\r\n"
    }
        
    let boundary = "Boundary-\(UUID().uuidString)"
    var encodedData: Data?
    private var parts = [BodyPart]()
    
    private struct BodyPart {
        let headers: [String: String]
        let data: Data

        init(headers: [String: String], data: Data) {
            self.headers = headers
            self.data = data
        }
    }
    
    func append(value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else {
            return
        }
        
        let headers = contentHeaders(name: key)
        parts.append(BodyPart(headers: headers, data: data))
    }
    
    func append(data: Data, name: String, fileName: String, mimetype: String? = nil) {
        let headers = contentHeaders(name: name, fileName: fileName, mimetype: mimetype)
        parts.append(BodyPart(headers: headers, data: data))
    }
    
    func encode() {
        var encoded = Data()
        encoded.append("--\(boundary)\(EncodingCharacters.crlf)".data(using: .utf8)!)
        
        for part in parts {
            encoded.append(encodeHeaders(part.headers))
            encoded.append(part.data)
            encoded.append(EncodingCharacters.crlf.data(using: .utf8)!)
        }
        
        encoded.append("--\(boundary)--\(EncodingCharacters.crlf)".data(using: .utf8)!)
        encodedData = encoded
    }
    
    private func encodeHeaders(_ headers: [String: String]) -> Data {
        var headerText = ""
        headers.forEach { headerText += "\($0): \($1)\(EncodingCharacters.crlf)" }
        headerText += EncodingCharacters.crlf
        return headerText.data(using: .utf8)!
    }
    
    private func contentHeaders(name: String, fileName: String? = nil, mimetype: String? = nil) -> [String: String] {
        var disposition = "form-data; name=\"\(name)\""
        if let fileName = fileName {
            disposition += "; filename=\"\(fileName)\""
        }
        
        var headers = ["Content-Disposition": disposition]
        if let mimetype = mimetype {
            headers["Content-Type"] = mimetype
        }
        
        return headers
    }
}
