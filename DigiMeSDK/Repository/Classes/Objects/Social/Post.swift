//
//  Post.swift
//  DigiMeSDK
//
//  Created on 25/09/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

@objcMembers
public class Post: NSObject, BaseObjectDecodable {
    
    public static var objectType: CAObjectType {
        return .post
    }
    
    /// The identifier of the account to which the post was made
    public var accountIdentifier: String {
        return accountEntityId ?? socialNetworkUserEntityId ?? ""
    }
    
    /// The date the post was created.
    public let createdDate: Date
    
    /// A unique identifier for the post
    public let identifier: String

    public let commentCount: Int
    public let favouriteCount: Int
    public var isCommentable: Bool {
        return isCommentableRaw != 0
    }
    
    public var isFavourited: Bool {
        return isFavouritedRaw != 0
    }
    
    public var isLikeable: Bool {
        return isLikeableRaw != 0
    }
    
    public var isLikes: Bool {
        return isLikesRaw != 0
    }
    
    public var isShared: Bool {
        return isSharedRaw != 0
    }
    
    public var isTruncated: Bool {
        return isTruncatedRaw != 0
    }
    
    public let latitude: Double
    public let likeCount: Int
    public let links: [Link]?
    public let longitude: Double
    public var originalPostIdentifier: String? {
        guard let originalPostId = originalPostIdentifierRaw else {
            return nil
        }
        return String(describing: originalPostId)
    }
    public let originalPostUrl: String
    public let personIdentifier: String
    public let personFileUrl: String
    public let personFullname: String
    public let personUsername: String
    public let postIdentifier: String
    public var postReplyCount: String? {
        guard let replayCount = postReplyCountRaw else {
            return nil
        }
        return String(describing: replayCount)
    }
    
    public let postUrl: String
    public let rawText: String?
    public let shareCount: Int
    public let source: String?
    public let text: String?
    public let title: String
    public var type: PostType {
        return PostType(rawValue: typeRaw) ?? .standard
    }
    
    public let updatedDate: Date
    public let userReaction: String?
//    public let viewCount: String
    public let visibility: String?
    public let baseIdentifier: String
    public let referenceIdentifier: String
    public let referenceEntityType: Int
    public let annotation: String?
    public let postEntityIdentifier: String?
    public let personFileRelativePath: String?
    public var originalCrossPostIdentifier: String? {
        guard let originalCrossPostId = originalCrossPostIdentifierRaw else {
            return nil
        }
        
        return String(describing: originalCrossPostId)
    }
    
    // MARK: - Objective-C Representations of non-optional primitives
//    @available(swift, obsoleted: 0.1)
//    public var latitudeAsNSNumber: NSNumber? {
//        return NSNumber(value: latitude)
//    }
    
    // MARK: - Raw Representations
    private let accountEntityId: String?
    private let socialNetworkUserEntityId: String?
    private let isCommentableRaw: Int
    private let isFavouritedRaw: Int
    private let isLikeableRaw: Int
    private let isLikesRaw: Int
    private let isSharedRaw: Int
    private let isTruncatedRaw: Int
    private let typeRaw: Int
    private let postReplyCountRaw: AnyJSONType?
    private let originalCrossPostIdentifierRaw: AnyJSONType?
    private let originalPostIdentifierRaw: AnyJSONType?
    
    // MARK: - Decodable
    enum CodingKeys: String, CodingKey {
        case accountEntityId = "accountentityid"
        case socialNetworkUserEntityId = "socialnetworkuserentityid"
        case createdDate = "createddate"
        case identifier = "entityid"
        case commentCount = "commentcount"
        case favouriteCount = "favouritecount"
        case isCommentableRaw = "iscommentable"
        case isFavouritedRaw = "isfavourited"
        case isLikeableRaw = "islikeable"
        case isLikesRaw = "islikes"
        case isSharedRaw = "isshared"
        case isTruncatedRaw = "istruncated"
        case latitude = "latitude"
        case likeCount = "likecount"
        case links = "links"
        case longitude = "longitude"
        case originalCrossPostIdentifierRaw = "originalcrosspostid"
        case originalPostIdentifierRaw = "originalpostid"
        case originalPostUrl = "originalposturl"
        case personIdentifier = "personentityid"
        case personFileUrl = "personfileurl"
        case personFullname = "personfullname"
        case personUsername = "personusername"
        case postIdentifier = "postid"
        case postReplyCountRaw = "postreplycount"
        case postUrl = "posturl"
        case rawText = "rawtext"
        case shareCount = "sharecount"
        case source = "source"
        case text = "text"
        case title = "title"
        case typeRaw = "type"
        case updatedDate = "updateddate"
        case userReaction = "userreaction"
//        case viewCount = "viewcount"
        case visibility = "visibility"
        case baseIdentifier = "baseid"
        case referenceIdentifier = "referenceentityid"
        case referenceEntityType = "referenceentitytype"
        case annotation = "annotation"
        case postEntityIdentifier = "postentityid"
        case personFileRelativePath = "personfilerelativepath"
    }
}

