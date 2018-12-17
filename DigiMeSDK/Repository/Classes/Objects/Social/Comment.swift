//
//  Comment.swift
//  DigiMeSDK
//
//  Created on 11/12/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.

import Foundation

@objcMembers
public class Comment: NSObject, BaseObjectDecodable {
    
    public var accountIdentifier: String {
        return accountEntityId ?? socialNetworkUserEntityId ?? ""
    }
    
    public let createdDate: Date
    
    public let identifier: String
    
    public static var objectType: CAObjectType {
        return .comment
    }
    
    public let personEntityId: String
    public let baseId: String
    public let referenceEntityId: String
    public let referenceEntityType: Int
    public let socialNetworkUserEntityId: String?
    public let updatedDate: Date?
    public let appId: String?
    public let commentCount: Int?
    public let commentId: String
    public let commentReplyId: String?
    public let likeCount: Int?
    public let link: String?
    public let metaId: String?
    public let personFileRelativePath: String?
    public let personFileUrl: String?
    public let personFullname: String?
    public let personUsername: String
    public let privacy: Int
    public let text: String?
    public let userReaction: String?
    
    // MARK: - Raw Representations
    private let accountEntityId: String?
    
    // MARK: - Decodable
    enum CodingKeys: String, CodingKey {
        case accountEntityId = "accountentityid"
        case socialNetworkUserEntityId = "socialnetworkuserentityid"
        case createdDate = "createddate"
        case identifier = "entityid"
        case personEntityId = "personentityid"
        case baseId = "baseid"
        case referenceEntityId = "referenceentityid"
        case referenceEntityType = "referenceentitytype"
        case updatedDate = "updateddate"
        case appId = "appid"
        case commentCount = "commentcount"
        case commentId = "commentid"
        case commentReplyId = "commentreplyid"
        case likeCount = "likecount"
        case link = "link"
        case metaId = "metaid"
        case personFileRelativePath = "personfilerelativepath"
        case personFileUrl = "personfileurl"
        case personFullname = "personfullname"
        case personUsername = "personusername"
        case privacy = "privacy"
        case text = "text"
        case userReaction = "userreaction"
    }
}
