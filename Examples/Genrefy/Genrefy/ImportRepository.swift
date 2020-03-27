//
//  ImportRepository.swift
//  TFP
//
//  Created on 14/08/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import DigiMeSDK

enum ServiceType: String {
    case facebook = "1"
    case twitter = "3"
    case instagram = "4"
    case pinterest = "9"
    case flickr = "12"
    
    var serviceTitle: String {
        switch self {
        case .facebook:
            return "Facebook"
        case .twitter:
            return "Twitter"
        case .instagram:
            return "Instagram"
        case .pinterest:
            return "Pinterest"
        case .flickr:
            return "Flickr"
        }
    }
    
    var tutorialFilename: String {
        switch self {
        case .facebook:
            return "tutorial-facebook"
        case .twitter:
            return "tutorial-twitter"
        case .instagram:
            return "tutorial-instagram"
        case .pinterest:
            return "tutorial-pinterest"
        case .flickr:
            return "tutorial-flickr"
        }
    }
    
    var tutorialServiceTitle: String {
        switch self {
        case .twitter:
            return "Tweets"
        case .pinterest:
            return "Pins"
        case .instagram,
             .facebook,
             .flickr:
            return "Posts"
        }
    }
    
    var serviceCode: String {
        switch self {
        case .facebook:
            return "1"
        case .twitter:
            return "3"
        case .instagram:
            return "4"
        case .pinterest:
            return "9"
        case .flickr:
            return "12"
        }
    }
    
    init?(name: String) {
        switch name.lowercased() {
        case "facebook":
            self = .facebook
        case "instagram":
            self = .instagram
        case "twitter":
            self = .twitter
        case "flickr":
            self = .flickr
        case "pinterest":
            self = .pinterest
        default:
            return nil
        }
    }
}

extension ServiceType {
    func icon() -> UIImage? {
        let image = UIImage(named: "service_\(self.rawValue)")
        return image
    }
    
    func color() -> UIColor {
        switch self {
        case .twitter:
            return #colorLiteral(red: 0.3725490196, green: 0.662745098, blue: 0.8666666667, alpha: 1)
        case .facebook:
            return #colorLiteral(red: 0.231372549, green: 0.3411764706, blue: 0.6156862745, alpha: 1)
        case .pinterest:
            return #colorLiteral(red: 0.7411764706, green: 0.03137254902, blue: 0.1098039216, alpha: 1)
        case .instagram:
            return #colorLiteral(red: 0.5137254902, green: 0.2274509804, blue: 0.7058823529, alpha: 1)
        case .flickr:
            return #colorLiteral(red: 1, green: 0, blue: 0.5176470588, alpha: 1)
        }
    }
}

@objc protocol ImportRepositoryDelegate {
    func repositoryDidUpdateProcessing(repository: ImportRepository)
    func repositoryDidFinishProcessing()
}

class ImportRepository: NSObject {
    
    var recentSongs = [Song]()
    var genresCounts = NSCountedSet()
    var orderedGenresSummaries: [GenreSummary] {
        return genresCounts.allObjects
            .compactMap { $0 as? String }
            .sorted { return genresCounts.count(for: $0) > genresCounts.count(for: $1) }
            .map { GenreSummary(title: $0, count: genresCounts.count(for: $0))}
    }
    var files = [DMEFile]()
    var accounts = [DMEAccount]()
    var objects: [CAResponseObject] = []
    var tfPosts: [TFPost] = []
    weak var delegate: ImportRepositoryDelegate?
    private var cache = TFPCache()
    
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
    }
    
    func postsForAccounts(_ filteredAccounts: [DMEAccount]) -> [TFPost]? {
        if accounts.count == filteredAccounts.count {
            return tfPosts
        }
        
        let accountIdentifiers = filteredAccounts.compactMap { $0.identifier }
        if accountIdentifiers.isEmpty {
            return nil
        }
        
        return tfPosts.filter { accountIdentifiers.contains($0.postObject.accountId) }
    }
    
    func objectsForAccounts(_ filteredAccounts: [DMEAccount]) -> [CAResponseObject]? {
        if accounts.count == filteredAccounts.count {
            return objects
        }
        
        let accountIdentifiers = filteredAccounts.compactMap { $0.identifier }
        if accountIdentifiers.isEmpty {
            return nil
        }
        
        return objects.filter { accountIdentifiers.contains($0.accountId) }
    }
    
    private func process(songs: [Song]) {
        let now = Date().timeIntervalSince1970
        let twentyFourHoursAgo = now - 24 * 60 * 60
        for song in songs {
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
    
    private func compute(data: [CAResponseObject]) {
        DispatchQueue.global(qos: .background).async {
            let startTime = CFAbsoluteTimeGetCurrent()
            let postProcessor = PostsProcessor()

            for obj in data {
                
                if let profanityResult = postProcessor.process(post: "\(obj.text) \(obj.title)") {
                    self.tfPosts.append(TFPost(postObject: obj, matchedWord: profanityResult.matchedString!, matchedIndex: profanityResult.index!))
                }
            }
            
            let elapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("Processed: \(data.count) posts in \(String(format: "%.2f", elapsed))")
            
            let cachedItems = self.cache.allItems()
            
            let matchingPosts = self.tfPosts.filter { cachedItems[$0.postObject.identifier] != nil }
            matchingPosts.forEach { $0.action = cachedItems[$0.postObject.identifier]! }
            
            DispatchQueue.main.async {
                self.delegate?.repositoryDidUpdateProcessing(repository: self)
            }
        }
    }
}
