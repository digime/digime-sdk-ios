//
//  PostMedia.swift
//  DigiMeSDK
//
//  Created on 25/09/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

@objcMembers
public class PostMedia: NSObject, BaseObjectDecodable {
    
    public static var objectType: CAObjectType {
        return .media
    }
    
    /// The identifier of the account to which the media was made
    public let accountIdentifier: String
    
    /// The date the media was created.
    public let createdDate: Date
    
    /// A unique identifier for the media
    public let identifier: String
    
    public let cameraModelIdentifier: String?
    public let commentCount: Int
    public let displayShortUrl: String?
    public let displayUrlIndexEnd: Int
    public let displayUrlIndexStart: Int
    public let filter: String?
    public let interestScore: Int
    public let latitude: Double?
    public let likeCount: Int
    public let link: String
    public let longitude: Double?
    public let mediaAlbumName: String
    public let mediaIdentifier: String
    public let mediaObjectIdentifier: String
    public let mediaObjectLikeIdentifier: String?
    public let name: String
    public var originatorType: Int {
        return originatorTypeRaw
    }
    public let personIdentifier: String
    public let personFileUrl: String
    public let personFullname: String
    public let personUsername: String
    public let postIdentifier: String?
    public let resources: [MediaResource]
    public let tagCount: Int?
    public let taggedPeopleCount: Int?
    public var type: MediaType {
        return MediaType(rawValue: typeRaw) ?? .image
    }
    public let updatedDate: Date
    public let baseIdentifier: String
    public let personFileRelativePath: String?
    public let locationIdentifier: String?
    public let itemLicenceIdentifier: String?
    public let imageFileIdentifier: String?
    public let imageFileRelativePath: String?
    public let imageFileUrl: String?
    
    /**
     URL of video, if media is a video.
     If `resources` are present, these will provide URLs for a range of resolutions with
     `videoFileUrl` being the first of those, irrespective of resolution
     */
    public let videoFileUrl: String?
    
    // MARK: - Objective-C Representations of non-optional primitives
    @available(swift, obsoleted: 0.1)
    public var latitudeAsNSNumber: NSNumber? {
        return NSNumber(value: latitude)
    }
    
    @available(swift, obsoleted: 0.1)
    public var longitudeAsNSNumber: NSNumber? {
        return NSNumber(value: longitude)
    }
    
    @available(swift, obsoleted: 0.1)
    public var tagCountAsNSNumber: NSNumber? {
        return NSNumber(value: tagCount)
    }
    
    @available(swift, obsoleted: 0.1)
    public var taggedPeopleCountAsNSNumber: NSNumber? {
        return NSNumber(value: taggedPeopleCount)
    }
    
    // MARK: - Raw Representations
    private let typeRaw: Int
    private let originatorTypeRaw: Int
    
    // MARK: - Decodable
    enum CodingKeys: String, CodingKey {
        case accountIdentifier = "accountentityid"
        case identifier = "entityid"
        case cameraModelIdentifier = "cameramodelentityid"
        case commentCount = "commentcount"
        case createdDate = "createddate"
        case displayShortUrl = "displayshorturl"
        case displayUrlIndexEnd = "displayurlindexend"
        case displayUrlIndexStart = "displayurlindexstart"
        case filter = "filter"
        case interestScore = "interestscore"
        case latitude = "latitude"
        case likeCount = "likecount"
        case link = "link"
        case longitude = "longitude"
        case mediaAlbumName = "mediaalbumname"
        case mediaIdentifier = "mediaid"
        case mediaObjectIdentifier = "mediaobjectid"
        case mediaObjectLikeIdentifier = "mediaobjectlikeid"
        case name = "name"
        case originatorTypeRaw = "originatortype"
        case personIdentifier = "personentityid"
        case personFileUrl = "personfileurl"
        case personFullname = "personfullname"
        case personUsername = "personusername"
        case postIdentifier = "postentityid"
        case resources = "resources"
        case tagCount = "tagcount"
        case taggedPeopleCount = "taggedpeoplecount"
        case typeRaw = "type"
        case updatedDate = "updateddate"
        case videoFileUrl = "videofileurl"
        case baseIdentifier = "baseid"
        case personFileRelativePath = "personfilerelativepath"
        case locationIdentifier = "locationentityid"
        case itemLicenceIdentifier = "itemlicenceentityid"
        case imageFileIdentifier = "imagefileentityid"
        case imageFileRelativePath = "imagefilerelativepath"
        case imageFileUrl = "imagefileurl"
    }
}
