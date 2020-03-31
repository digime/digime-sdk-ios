//
//  PersistentStorage.swift
//  Genrefy
//
//  Created on 30/03/2020.
//  Copyright © 2020 digi.me. All rights reserved.
//

import Foundation

public class PersistentStorage {
    
    static let shared = PersistentStorage()
    
    private func getURL() -> URL? {
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        return url
    }

    func store(data: Data, fileName: String) {
        guard
            !data.isEmpty,
            let url = getURL()?.appendingPathComponent(fileName, isDirectory: false) else {
                return
        }
        
        if dataPersist(for: fileName) {
            try? FileManager.default.removeItem(at: url)
        }
        
        FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
    }

    func loadData(for fileName: String) -> Data? {
        guard
            let url = getURL()?.appendingPathComponent(fileName, isDirectory: false),
            let data = FileManager.default.contents(atPath: url.path) else {
                return nil
        }
        
        return data
    }

    func reset(fileName: String) {
        guard let url = getURL()?.appendingPathComponent(fileName, isDirectory: false) else {
            return
        }
        
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    func dataPersist(for fileName: String) -> Bool {
        guard let url = getURL()?.appendingPathComponent(fileName, isDirectory: false) else {
            return false
        }
        
        return FileManager.default.fileExists(atPath: url.path)
    }
}
