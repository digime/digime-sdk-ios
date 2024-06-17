//
//  String+Helper.swift
//  DigiMeSDKExample
//
//  Created on 09/03/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

extension String {
    func trimAndReduceSpaces() -> String {
        // Trim whitespace from both ends of the string
        let trimmedString = self.trimmingCharacters(in: .whitespacesAndNewlines)

        // Replace multiple spaces with a single space
        let singleSpacedString = trimmedString.replacingOccurrences(of: "[ ]+", with: " ", options: .regularExpression)

        return singleSpacedString
    }
}

extension String {
    /// Returns a version of the string with escaped sequences replaced.
    var unescaped: String {
        var result = self
        let replacements: [String: String] = [
            "\\\\": "\\",
            "\\\"": "\"",
            "\\t": "\t",
            "\\n": "\n",
            "\\r": "\r",
        ]

        replacements.forEach { escaped, unescaped in
            result = result.replacingOccurrences(of: escaped, with: unescaped)
        }

        return result
    }
}

extension String {
    /// Returns a version of the string with all backslashes removed.
    var withoutBackslashes: String {
        return self.replacingOccurrences(of: "'\'", with: "")
    }
}
