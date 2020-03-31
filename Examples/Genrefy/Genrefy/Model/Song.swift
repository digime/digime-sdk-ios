//
//  Song.swift
//  Genrefy
//
//  Created on 25/03/2020.
//  Copyright © 2020 digi.me. All rights reserved.
//

import Foundation

struct Song: Codable {
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
}

fileprivate struct Track: Codable {
    let artists: [Artist]
}

fileprivate struct Artist: Codable {
    let genres: [String]
}
