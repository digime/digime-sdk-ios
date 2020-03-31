//
//  Song.swift
//  Genrefy
//
//  Created on 25/03/2020.
//  Copyright © 2020 digi.me. All rights reserved.
//

import Foundation

class Song: Codable {
    var genres: Set<String> {
        return Set(track.artists.flatMap { $0.genres })
    }
    
    var lastListenedTimestamp: TimeInterval {
        createdDate / 1000
    }
    
    let accountIdentifier: String
    let identifier: String
    
    private let createdDate: Double
    private let track: Track
    
    enum CodingKeys: String, CodingKey {
        case identifier = "entityid"
        case accountIdentifier  = "accountentityid"
        case createdDate = "createddate"
        case track
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(String.self, forKey: .identifier)
        accountIdentifier = try container.decode(String.self, forKey: .accountIdentifier)
        createdDate = try container.decode(Double.self, forKey: .createdDate)
        track = try container.decode(Track.self, forKey: .track)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.accountIdentifier, forKey: .accountIdentifier)
        try container.encode(self.createdDate, forKey: .createdDate)
        try container.encode(self.track, forKey: .track)
     }
}

fileprivate class Track: Codable {
    let artists: [Artist]
    
    enum CodingKeys: String, CodingKey {
        case artists
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        artists = try container.decode([Artist].self, forKey: .artists)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.artists, forKey: .artists)
     }
}

fileprivate class Artist: Codable {
    let genres: [String]
    
    enum CodingKeys: String, CodingKey {
        case genres
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        genres = try container.decode([String].self, forKey: .genres)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.genres, forKey: .genres)
     }
}

extension Song {
    class func genres(from jsonString: String) -> [Song] {
        let data = jsonString.data(using: .utf8)!
        return self.songs(from: data)
    }
    
    class func songs(from data: Data) -> [Song] {
        return (try? JSONDecoder().decode([Song].self, from: data)) ?? []
    }

    class func data(from songs: [Song]) -> Data {
        return (try? JSONEncoder().encode(songs)) ?? Data()
    }
}
