//
//  DMERepository.swift
//  DigiMeRepository
//
//  Created on 11/07/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

@objc public final class DMERepository: NSObject {
    private var dataReader: DMEDataReader
    private var dataWriter: DMEDataWriter
    private var downloadedCount = 0 {
        didSet {
            let downloadedCount = self.downloadedCount
            let erroredCount = self.erroredCount
            DispatchQueue.main.async {
                let total = self.filesToDownloadCount
                let progressPercentage = Int((Float(downloadedCount) / Float(total)) * 100)
                self.delegate?.repositoryUpdated(progress: progressPercentage)
                
                if downloadedCount + erroredCount == total {
                    self.delegate?.repositoryDidFinishUpdate()
                }
            }
        }
    }
    private var filesToDownloadCount = 0
    private static let kFileLocation = "CARepository/"
    private let kAccountsFileName = "accounts.json"
    
    /// Locking queue for accessing progress count
    private let internalQueue = DispatchQueue(label: "LockingQueue")
    private var erroredCount = 0 {
        didSet {
            let downloadedCount = self.downloadedCount
            let erroredCount = self.erroredCount
            if downloadedCount + erroredCount == self.filesToDownloadCount {
                DispatchQueue.main.async {
                    self.delegate?.repositoryDidFinishUpdate()
                }
            }
        }
    }
    private var retryAttempt = 0
    private let kMaxRetryAttempts = 3
    
    public let client = DMEClient.shared()
    public weak var delegate: DMERepositoryDelegate?
    
    override public init() {
        let fileLocation = DMERepository.caDirectory()
        dataReader = DMEDataReader(fileLocation: fileLocation)
        dataWriter = DMEDataWriter(fileLocation: fileLocation)
        super.init()
        client.downloadDelegate = self
        client.decryptsData = false
        
//        let accounts = self.accounts
        
//        self.query(Transaction.self, dateRange: nil, predicate: { transaction -> Bool in
//            transaction.amount > 0
//        }, completion: { transactions in
//            guard transactions != nil else {
//                return
//            }
//        })
        
//        self.query(Post.self, dateRange: nil, predicate: nil, completion: { transactions in
//            guard transactions != nil else {
//                return
//            }
//        })
        
        self.query(PostMedia.self, dateRange: nil, predicate: nil) { transactions in
            guard transactions != nil else {
                return
            }
        }
    }
    
    @objc public func update() {
        client.getFileList()
        client.getAccounts()
        
        filesToDownloadCount = 1 // accounts
    }
    
    @objc public func hasData() -> Bool {
        let data = dataReader.read(kAccountsFileName)
        return data != nil
    }
    
    @objc public var accounts: [Account]? {
        guard let data = dataReader.read(kAccountsFileName) else {
            return nil
        }
        if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
            print(json)
        }
        
        var objects: [Account]?
        do {
            let decoder = JSONDecoder()
            let accountsContainer = try decoder.decode(AccountsContainer.self, from: data)
            objects = accountsContainer.accounts
        }
        catch {
            print(error)
        }
        
        return objects
    }
    
    @available(swift, obsoleted: 0.9)
    @objc public func queryForClass(_ type: BaseObject.Type, dateRange: DateInterval?, predicate: ((BaseObject) -> Bool)?, completion: @escaping (([BaseObject]?) -> Void)) {
        if let type = type as? Transaction.Type {
            query(type, dateRange: dateRange, predicate: predicate, completion: completion)
        }
    }
    
    public func query<T>(_ type: T.Type, dateRange: DateInterval?, predicate: ((T) -> Bool)?, completion: @escaping (([T]?) -> Void)) where T: BaseObjectDecodable {
        guard let files = dataReader.listFiles() else {
            completion(nil)
            return
        }
        
        let objectType = T.objectType
        
        // Select relevant files with matching object type
        var relevantFiles = files.filter { $0.objectType == objectType }
        
        // Further select files included in date range, if applicable
        if let queryDateRange = dateRange {
            relevantFiles = relevantFiles.filter { file in
                guard let fileDateRange = file.dateRange else {
                    return true
                }
                
                return queryDateRange.intersects(fileDateRange)
            }
        }
        
        // Retrieve objects from selected files
        var relevantObjects = [T]()
        for file in relevantFiles {
            guard let data = dataReader.read(file.fileName) else {
                continue
            }
            if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                print(json)
            }

            do {
                let objects = try T.decoder.decode([T].self, from: data)
                relevantObjects.append(contentsOf: objects)
            }
            catch {
                print(error)
            }
        }
        
        // Select objects included in date range, if applicable
        if let queryDateRange = dateRange {
            relevantObjects = relevantObjects.filter { queryDateRange.contains($0.createdDate) }
        }
        
        // Let caller select remaining objects based on their predicate
        if let predicate = predicate {
            relevantObjects = relevantObjects.filter(predicate)
        }
        
        completion(relevantObjects)
    }
}

extension DMERepository {
    class func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    class func caDirectory() -> URL {
        return self.documentsDirectory().appendingPathComponent(self.kFileLocation)
    }
}

extension DMERepository: DMEClientDownloadDelegate {
    
    public func clientRetrievedFileList(_ files: CAFiles) {
        filesToDownloadCount += files.fileIds.count
        
        for file in files.fileIds {
            client.getFileWithId(file)
        }
    }
    
    public func clientFailed(toRetrieveFileList error: Error) {
        print("\(#function): \(error)")
        self.delegate?.repositoryDidError(error: error)
    }
    
    public func fileRetrieveFailed(_ fileId: String, error: Error) {
        print("\(#function): (\(fileId)) \(error)")
        self.delegate?.repositoryDidError(error: error)
        self.internalQueue.sync { self.erroredCount += 1 }
    }
    
    public func dataRetrieved(_ data: Data, fileId: String) {
        dataWriter.write(data: data, fileId: fileId) { error in
            
            if let error = error {
                self.delegate?.repositoryDidError(error: error)
            }
            
            self.internalQueue.sync { self.downloadedCount += 1 }
        }
    }
    
    public func accountsRetrieveFailed(_ error: Error) {
        print("\(#function): \(error)")
        self.delegate?.repositoryDidError(error: error)
        self.internalQueue.sync { self.erroredCount += 1 }
    }
    
    public func accountsDataRetrieved(_ data: Data) {
        dataWriter.write(data: data, fileId: kAccountsFileName) { error in
            if let error = error {
                self.delegate?.repositoryDidError(error: error)
            }
            
            self.internalQueue.sync {
                self.downloadedCount += 1
            }
        }
    }
}
