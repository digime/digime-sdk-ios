//
//  FileHelper.swift
//  DigiMeSDKExample
//
//  Created by Alex Hamilton on 31/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

class FileHelper {
    static func saveToDocumentDirectory(data: Data, fileName: String) -> URL? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to get document directory")
            return nil
        }

        let fileURL = documentDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            return fileURL
        } 
        catch {
            print("Error saving file: \(error)")
            return nil
        }
    }
}
