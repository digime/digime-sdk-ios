//
//  Atomic.swift
//  DigiMeSDK
//
//  Created on 05/08/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Makes a property atomic.
/// NB. Only use for scalar value types - does not work for collections or dictionaries
@propertyWrapper struct Atomic<Value> {
    private let queue = DispatchQueue(label: "me.digi.sdk.atomicQueue.\(UUID().uuidString)")
    private var value: Value

    var wrappedValue: Value {
        get {
            queue.sync { value }
        }
        set {
            queue.sync { value = newValue }
        }
    }

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }
}
