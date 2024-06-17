//
//  ModelContext+Helper.swift
//  DigiMeSDKExample
//
//  Created on 22/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation
import SwiftData

extension ModelContext {
    func deleteAll<T>(model: T.Type) where T: PersistentModel {
        do {
            let p = #Predicate<T> { _ in true }
            try self.delete(model: T.self, where: p, includeSubclasses: false)
            print("All of \(model.self) cleared !")
        }
        catch {
            print("error: \(error)")
        }
    }
}
