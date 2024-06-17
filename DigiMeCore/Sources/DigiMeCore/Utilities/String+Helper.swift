//
//  String+Helper.swift
//  DigiMeSDK
//
//  Created on 19/03/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

extension String {
    public static func random(length: Int) -> String {
        var result = String()
        for _ in 1...length {
            result += "\(Int.random(in: 1...9))"
        }
        
        return result
    }

    /// Removes the file extension from the string.
    ///
    /// This method assumes the string is a file name or file path and removes the extension.
    ///
    /// - Returns: A new string without the file extension.
    public func deletingPathExtension() -> String {
        let nsString = self as NSString
        return nsString.deletingPathExtension
    }
}
