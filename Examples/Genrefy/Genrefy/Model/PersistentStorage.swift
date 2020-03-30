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
    let fileName = "analyseResult.json"
    
    private func getURL() -> URL? {
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        return url
    }

    func store(genres: [GenreSummary]) {
        guard
            !genres.isEmpty,
            let url = getURL()?.appendingPathComponent(fileName, isDirectory: false) else {
                return
        }
        
        if dataPersist() {
            try? FileManager.default.removeItem(at: url)
        }
        
        let data = GenreSummary.data(from: genres)
        FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
    }

    func loadGenres() -> [GenreSummary]? {
        guard
            let url = getURL()?.appendingPathComponent(fileName, isDirectory: false),
            let data = FileManager.default.contents(atPath: url.path) else {
                return nil
        }
        
        return GenreSummary.genres(from: data)
    }

    func reset() {
        guard let url = getURL()?.appendingPathComponent(fileName, isDirectory: false) else {
            return
        }
        
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    func dataPersist() -> Bool {
        guard let url = getURL()?.appendingPathComponent(fileName, isDirectory: false) else {
            return false
        }
        
        return FileManager.default.fileExists(atPath: url.path)
    }
}
