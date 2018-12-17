//
//  BaseObject.swift
//  DigiMeSDK
//
//  Created on 18/09/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

@objc public protocol BaseObject: NSObjectProtocol {
    var accountIdentifier: String { get }
    var createdDate: Date { get }
    var identifier: String { get }
    
    static var objectType: CAObjectType { get }
}

public protocol BaseObjectDecodable: BaseObject, Decodable {
}

extension BaseObject {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }
}
