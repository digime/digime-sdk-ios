//
//  FilePersistentStorage.swift
//  DigiMeSDK
//
//  Created on 23/02/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

public class FilePersistentStorage {
    
    private var location: FileManager.SearchPathDirectory = .documentDirectory
    
    public required init(with location: FileManager.SearchPathDirectory) {
        self.location = location
    }
    
    private func getURL() -> URL? {
        guard let url = FileManager.default.urls(for: location, in: .userDomainMask).first else {
            return nil
        }
        
        return url
    }

    public func store(data: Data, fileName: String) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.store(data: data, fileName: fileName)
            }
            
            return
        }
        
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
    
    public func store(file: File) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.store(file: file)
            }
            
            return
        }
        
        guard let url = getURL()?.appendingPathComponent(file.identifier, isDirectory: false) else {
            return
        }
        
        if dataPersist(for: file.identifier) {
            try? FileManager.default.removeItem(at: url)
        }

        if
            let newData = try? file.encoded(dateEncodingStrategy:  .millisecondsSince1970, keyEncodingStrategy: .convertToSnakeCase),
            let jsonStr = String(data: newData, encoding: .utf8) {
            
            try? jsonStr.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    public func store(object: Any, fileName: String, options: JSONSerialization.WritingOptions = []) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.store(object: object, fileName: fileName, options: options)
            }
            
            return
        }
        
        guard let url = getURL()?.appendingPathComponent(fileName, isDirectory: false) else {
            return
        }
        
        if dataPersist(for: fileName) {
            try? FileManager.default.removeItem(at: url)
        }

        if
            JSONSerialization.isValidJSONObject(object as Any),
            let newData = try? JSONSerialization.data(withJSONObject: object, options: options),
            let jsonStr = String(data: newData, encoding: .utf8) {
            
            try? jsonStr.write(to: url, atomically: true, encoding: .utf8)
        }
    }

    public func loadData(for fileName: String) -> Data? {
        guard
            let url = getURL()?.appendingPathComponent(fileName, isDirectory: false),
            let data = FileManager.default.contents(atPath: url.path) else {
                return nil
        }
        
        return data
    }

    public func reset(fileName: String) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.reset(fileName: fileName)
            }
            
            return
        }
        
        guard let url = getURL()?.appendingPathComponent(fileName, isDirectory: false) else {
            return
        }
        
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    public func dataPersist(for fileName: String) -> Bool {
        guard let url = getURL()?.appendingPathComponent(fileName, isDirectory: false) else {
            return false
        }
        
        return FileManager.default.fileExists(atPath: url.path)
    }
}
