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
    
    public var createdDate: Date
    
    public let identifier: String
    
    public static var objectType: CAObjectType {
        return .comment
    }
    
    public let personEntityId: String
    
    public let baseId: String
//    public let entityId: String
    public let referenceEntityId: String
    public let referenceEntityType: Int
    public let socialNetworkUserEntityId: String?
    public let updatedDate: Date
    
    public let appId: String
    public let commentCount: Int
    public let commentId: String
    public let commentReplyId: String
    public let likeCount: Int
    public let link: String
    public let metaId: String
    public let personFileRelativePath: String
    public let personFileUrl: String
    public let personFullname: String
    public let personUsername: String
    public let privacy: Int
    public let text: String
    public let userReaction: String?
    
    // MARK: - Raw Representations
    private let accountEntityId: String?
    
    // MARK: - Decodable
    enum CodingKeys: String, CodingKey {
        case accountEntityId = "accountentityid"
        case socialNetworkUserEntityId = "socialnetworkuserentityid"
//        case accountIdentifier = "accountentityid"
        case createdDate = "createddate"
        case identifier = "entityid"
//        case objectType = "objecttype"
        
        case personEntityId = "personentityid"
        
//        case accountEntityId = "accountentityid"
        case baseId = "baseid"
//        case entityId = "entityid"
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
    
    override private init() {
        accountEntityId = ""
        
        createdDate = Date()
        
        identifier = ""
        
//        objectType: CAObjectType
        
        personEntityId = ""
        
        baseId = ""
//        entityId = ""
        referenceEntityId = ""
        referenceEntityType = 0
        socialNetworkUserEntityId = ""
        updatedDate = Date()
        
        appId = ""
        commentCount = 0
        commentId = ""
        commentReplyId = ""
        likeCount = 0
        link = ""
        metaId = ""
        personFileRelativePath = ""
        personFileUrl = ""
        personFullname = ""
        personUsername = ""
        privacy = 0
        text = ""
        userReaction = ""
    }
}
