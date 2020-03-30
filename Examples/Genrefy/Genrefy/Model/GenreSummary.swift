//
//  GenreSummary.swift
//  Genrefy
//
//  Created on 26/03/2020.
//  Copyright © 2020 digi.me. All rights reserved.
//

import Foundation

class GenreSummary: Codable {
    let title: String
    let count: Int
    
    init(title: String, count: Int) {
        self.title = title
        self.count = count
    }
    
    enum CodingKeys: String, CodingKey {
        case title, count
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        count = try container.decode(Int.self, forKey: .count)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.count, forKey: .count)
     }
}

extension GenreSummary {
    class func genres(from jsonString: String) -> [GenreSummary] {
        let data = jsonString.data(using: .utf8)!
        return self.genres(from: data)
    }
    
    class func genres(from data: Data) -> [GenreSummary] {
        return (try? JSONDecoder().decode([GenreSummary].self, from: data)) ?? []
    }

    class func data(from genres: [GenreSummary]) -> Data {
        return (try? JSONEncoder().encode(genres)) ?? Data()
    }
}
