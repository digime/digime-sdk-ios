//
//  ImportRepository.swift
//  Genrefy
//
//  Created on 14/08/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import DigiMeSDK

enum ServiceType: String {
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

@objc protocol ImportRepositoryDelegate {
    func repositoryDidUpdateProcessing(repository: ImportRepository)
}

class ImportRepository: NSObject {
    
    var recentSongs = [Song]()
    var genresCounts = NSCountedSet()
    var allOrderedGenreSummaries: [GenreSummary] {
        return orderedGenreSummaries(for: genresCounts)
    }
    var files = [DMEFile]()
    var accounts = [DMEAccount]()
    weak var delegate: ImportRepositoryDelegate?
    
    func process(file: DMEFile) {
        files.append(file)
        guard file.fileId.contains("_406_") else {
            print("Unexpected file \(file.fileId)")
            return
        }
        
        do {
            let songArray = try JSONDecoder().decode([Song].self, from: file.fileContent)
            process(songs: songArray)
            
            DispatchQueue.main.async {
                self.delegate?.repositoryDidUpdateProcessing(repository: self)
            }
        }
        catch {
            print("Error decoding play history data for file \(file.fileId): \(error)")
        }
    }
    
    func process(accounts: DMEAccounts) {
        if let accounts = accounts.accounts {
            self.accounts = accounts
        }
        
        if
            let accountsDictionary = accounts.json,
            let accountsData = try? NSKeyedArchiver.archivedData(withRootObject: accountsDictionary, requiringSecureCoding: false) {
                PersistentStorage.shared.store(data: accountsData, fileName: "accounts.json")
        }
    }
    
    func genreSummariesForAccounts(_ filteredAccounts: [DMEAccount]) -> [GenreSummary] {
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
