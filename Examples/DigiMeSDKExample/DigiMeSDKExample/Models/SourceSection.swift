//
//  SourceSection.swift
//  DigiMeSDKExample
//
//  Created on 02/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation
import SwiftUI

struct SourceSection: Codable, Identifiable {
    let id: Int
    let title: String
    var itemCount: Int = 0
}

extension SourceSection {
    var iconName: String {
        switch id {
        case 1:
            return "socialIcon"
        case 2:
            return "healthIcon"
        case 3:
            return "financeIcon"
        case 4:
            return "healthIcon"
        case 5:
            return "entertainmentIcon"

        default:
            return ""
        }
    }
}
