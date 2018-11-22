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
        
        let containers = filePaths.compactMap { FileContainer(withFileDescriptor: $0) }
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
            decryptedData = try CADataDecryptor.decrypt(fileData)
        }
        catch {
            print(error)
        }
        
        return decryptedData
    }
}
