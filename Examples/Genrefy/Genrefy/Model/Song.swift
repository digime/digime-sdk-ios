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
        createddate / 1000
    }
    
    private let createddate: Double
    private let track: Track
}

fileprivate struct Track: Codable {
    let artists: [Artist]
}

fileprivate struct Artist: Codable {
    let genres: [String]
}
