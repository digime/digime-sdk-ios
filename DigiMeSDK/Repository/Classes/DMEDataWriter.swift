//
//  DMEDataWriter.swift
//  DigiMeSDK
//
//  Created on 11/07/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

class DMEDataWriter {
    private var queue: OperationQueue = {
       let q = OperationQueue()
        q.maxConcurrentOperationCount = 5
        return q
    }()
    
    private let fileLocation: URL
    
    init(fileLocation: URL) {
        self.fileLocation = fileLocation
        let fileManager = FileManager.default
        let caPath = fileLocation.relativePath
        let exists = fileManager.fileExists(atPath: caPath)
        
        guard !exists else {
            return
        }
        
        do {
            try FileManager.default.createDirectory(atPath: caPath, withIntermediateDirectories: false, attributes: nil)
        }
        catch {
            print(error.localizedDescription)
            return
        }
    }
    
    func write(data: Data, fileId: String, completion: @escaping (Error?) -> Void) {
        queue.addOperation {
            //save file on disk
            let filepath = self.fileLocation.appendingPathComponent(fileId)
            
            do {
                try data.write(to: filepath, options: .atomic)
            }
            catch {
                completion(error)
                return
            }
            
            completion(nil)
        }
    }
}
