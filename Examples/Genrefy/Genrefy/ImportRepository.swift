//
//  ImportRepository.swift
//  Genrefy
//
//  Created on 14/08/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import DigiMeSDK
import Foundation

enum ServiceTypeConverter: String {
    case spotify = "19"
    
    init?(name: String) {
        switch name.lowercased() {
        case "spotify":
            self = .spotify
        default:
            return nil
        }
    }
}

protocol ImportRepositoryDelegate: AnyObject {
    func repositoryDidUpdateProcessing(repository: ImportRepository)
}

class ImportRepository: NSObject {
    
    var recentSongs = [Song]()
    var genresCounts = NSCountedSet()
    var allOrderedGenreSummaries: [GenreSummary] {
        return orderedGenreSummaries(for: genresCounts)
    }
    var files = [File]()
    var accounts = [SourceAccount]()
    weak var delegate: ImportRepositoryDelegate?
    
    func process(file: File) {
        files.append(file)
        
        let metadata: MappedFileMetadata? = {
            switch file.metadata {
            case .mapped(let metadata):
                return metadata
            default:
                return nil
            }
        }()
        
        guard metadata?.objectType == "playhistory" else {
            print("Unexpected file \(file.identifier)")
            return
        }
        
        do {
            let songArray = try JSONDecoder().decode([Song].self, from: file.data)
            process(songs: songArray)
            
            DispatchQueue.main.async {
                self.delegate?.repositoryDidUpdateProcessing(repository: self)
            }
        }
        catch {
            print("Error decoding play history data for file \(file.identifier): \(error)")
        }
    }
    
    func process(accountsInfo: AccountsInfo) {
        accounts = accountsInfo.accounts
        
        if let accountsData = try? JSONEncoder().encode(accounts) {
            PersistentStorage.shared.store(data: accountsData, fileName: "accounts.json")
        }
    }
    
    func genreSummariesForAccounts(_ filteredAccounts: [SourceAccount]) -> [GenreSummary] {
        if accounts.count == filteredAccounts.count {
            return allOrderedGenreSummaries
        }
        
        let accountIdentifiers = filteredAccounts.compactMap { $0.identifier }
        if accountIdentifiers.isEmpty {
            return []
        }
        
        let filteredSongs = recentSongs.filter { accountIdentifiers.contains($0.accountIdentifier) }
        let countedSet = NSCountedSet()
        for song in filteredSongs {
            let genres = song.genres
            for genre in genres {
                countedSet.add(genre)
            }
        }
        
        return orderedGenreSummaries(for: countedSet)
    }
    
    func process(songs: [Song]) {
        let now = Date().timeIntervalSince1970
        let twentyFourHoursAgo = now - 24 * 60 * 60
        for song in songs {
            // Only process new songs
            guard !recentSongs.contains(where: { $0.identifier == song.identifier}) else {
                continue
            }
            
            // Only process songs listened to in last 24 hours
            guard song.lastListenedTimestamp > twentyFourHoursAgo else {
                continue
            }
            
            recentSongs.append(song)
            let genres = song.genres
            for genre in genres {
                genresCounts.add(genre)
            }
        }
    }
    
    private func orderedGenreSummaries(for countedSet: NSCountedSet) -> [GenreSummary] {
        return countedSet.allObjects
            .compactMap { $0 as? String }
            .sorted { return countedSet.count(for: $0) > countedSet.count(for: $1) }
            .map { GenreSummary(title: $0, count: countedSet.count(for: $0))}
    }
}
