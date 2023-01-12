//
//  Writable.swift
//  DigiMeSDK
//
//  Created on 25.09.20.
//

import Foundation

protocol Original {
    associatedtype Object: NSObject

    func asOriginal() throws -> Object
}
