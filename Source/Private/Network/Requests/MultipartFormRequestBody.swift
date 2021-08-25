//
//  MultipartFormRequestBody.swift
//  DigiMeSDK
//
//  Created on 04/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct MultipartFormRequestBody: RequestBody {
    var headers: [String: String] {
        [
            "Content-Type": "multipart/form-data; boundary=\(formData.boundary)",
            "Content-Length": "\(formData.encodedData?.count ?? 0)",
            "Accept": "application/json",
        ]
    }
    
    var data: Data {
        formData.encodedData ?? Data()
    }
    
    private var formData = MultipartFormData()
    
    func setData(block: (MultipartFormData) -> Void) {
        block(formData)
        formData.encode()
    }
}
