//
//  DMEDataReader.swift
//  DigiMeRepository
//
//  Created on 20/09/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

class DMEDataReader {
    
    private let fileLocation: URL
    
    init(fileLocation: URL) {
        self.fileLocation = fileLocation
    }
    
    func listFiles() -> [FileContainer]? {
        let fileManager = FileManager.default
        let caPath = fileLocation.relativePath
        guard let filePaths = try? fileManager.contentsOfDirectory(atPath: caPath) else {
            return nil
        }
        
        let containers = filePaths.compactMap { fileName -> FileContainer? in
            let file = FileContainer(withFileDescriptor: fileName)
            file?.created = date(fileName, dateAttribute: FileAttributeKey.creationDate)
            file?.modified = date(fileName, dateAttribute: FileAttributeKey.modificationDate)
            return file
        }
        return containers
    }
    
    func read(_ fileName: String) -> Data? {
        let filepath = self.fileLocation.appendingPathComponent(fileName)
        let fileManager = FileManager.default
        guard let fileData = fileManager.contents(atPath: filepath.relativePath) else {
            return nil
        }
        
        var decryptedData: Data?
        do {
            decryptedData = try DMEDataUnpacker.unpack(fileData)
        }
        catch {
            print(error)
        }
        
        return decryptedData
    }
    
    func date(_ fileName: String, dateAttribute: FileAttributeKey) -> Date? {
        let filepath = self.fileLocation.appendingPathComponent(fileName)
        let fileManager = FileManager.default
        
        do {
            let attr = try fileManager.attributesOfItem(atPath: filepath.path)
            return attr[dateAttribute] as? Date
        }
        catch {
            return nil
        }
    }
}
