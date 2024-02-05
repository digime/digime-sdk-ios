//
//  CustomActionPickerViewButtonData.swift
//  DigiMeSDKExample
//
//  Created on 20/01/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

struct CustomActionPickerViewButtonData: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let action: () -> Void

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(subtitle)
    }
}

extension CustomActionPickerViewButtonData: Equatable {
    static func == (lhs: CustomActionPickerViewButtonData, rhs: CustomActionPickerViewButtonData) -> Bool {
        return lhs.id == rhs.id
    }
}
