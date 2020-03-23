//
//  CAResponseObject.swift
//  TFP
//
//  Created on 14/08/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation

class CAResponseObject: Decodable {
    
    var createdDate: Date
    var likeCount: Int
    var commentCount: Int
    var shareCount: Int
    var personId: String
    var accountId: String
    var postId: String
    var text: String
    var title: String
    var latitude: Double?
    var longitude: Double?
    var serviceType: ServiceType?
    var username: String
    var postUrl: String
    var identifier: String
    
    private enum CodingKeys: String, CodingKey {
        case createdDate = "createddate"
        case likeCount = "likecount"
        case commentCount = "commentcount"
        case shareCount = "sharecount"
        case personId = "personentityid"
        case accountId = "accountentityid"
        case postId = "postid"
        case text
        case title
        case latitude
        case longitude
        case serviceType = "servicetype"
        case username = "personusername"
        case postUrl = "posturl"
        case identifier = "entityid"
    }
    
    var popularityCount: Int {
        var count = 0
        count += likeCount
        count += commentCount
        count += shareCount
        return count
    }
    var isMyPost: Bool {
        guard let serviceType = serviceType else {
            return false
        }
        
         if
            serviceType == .instagram {
            if
                let accountId = accountId.components(separatedBy: "_").last,
                let postId = postId.components(separatedBy: "_").last,
                accountId == postId
            {
                return true
            }
        }
        else if
            let personId = personId.components(separatedBy: "_").last,
            let accountId = accountId.components(separatedBy: "_").last,
            personId == accountId
        {
                return true
        }
        
        return false
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let createdTimeStamp = try values.decode(TimeInterval.self, forKey: .createdDate)
        createdDate = Date(timeIntervalSince1970: createdTimeStamp / 1000)
        //createdDate = try values.decode(Date.self, forKey: .createdDate)
        
        likeCount = try values.decode(Int.self, forKey: .likeCount)
        commentCount = try values.decode(Int.self, forKey: .commentCount)
        shareCount = try values.decode(Int.self, forKey: .shareCount)
        personId = try values.decode(String.self, forKey: .personId)
        accountId = try values.decode(String.self, forKey: .accountId)
        postId = try values.decode(String.self, forKey: .postId)
        text = try values.decode(String.self, forKey: .text)
        title = try values.decode(String.self, forKey: .title)
        latitude = try values.decode(Double.self, forKey: .latitude)
        longitude = try values.decode(Double.self, forKey: .longitude)
        username = try values.decode(String.self, forKey: .username)
        postUrl = try values.decode(String.self, forKey: .postUrl)
        identifier = try values.decode(String.self, forKey: .identifier)
    }
}
