//
//  String+Helper.swift
//  DigiMeSDKExample
//
//  Created on 11/02/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Localization.module, value: "", comment: "")
    }

    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized(), arguments: arguments)
    }
}
