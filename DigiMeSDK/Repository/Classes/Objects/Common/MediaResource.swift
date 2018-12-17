//
//  MediaResource.swift
//  DigiMeSDK
//
//  Created on 25/09/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

@objcMembers
public class MediaResource: NSObject, Decodable {
    /// Aspect ratio of media.
    /// Optional for videos.
    public let aspectRatio: AspectRatio?
    
    /// Media bitrate.  Available for videos
    public let bitrate: Int?
    
    /// Duration of media.  Available for videos
    public let duration: Int?
    
    /// Height of media in pixels.
    /// Optional for videos.
    public let height: Int?
    
    /// The type of media e.g. "image/jpeg", "video/mp4"
    public let mimeType: String
    
    /// How best to display media when container is different size: "fit", "aspect fill".
    /// Available for images
    public let resize: String?
    
    /// Media type
    public var type: MediaType {
        return MediaType(rawValue: typeRaw) ?? .image
    }
    
    /// URL of media
    public let url: String
    
    /// Width of media in pixels.
    /// Optional for videos.
    public let width: Int?
    
    private let typeRaw: Int
    
    public required init(from decoder: Decoder) throws {
        let resource = try decoder.container(keyedBy: CodingKeys.self)
        
        aspectRatio = try resource.decodeIfPresent(AspectRatio.self, forKey: .aspectRatio)
        bitrate = try resource.decodeIfPresent(Int.self, forKey: .bitrate)
        duration = try resource.decodeIfPresent(Int.self, forKey: .duration)
        mimeType = try resource.decode(String.self, forKey: .mimeType)
        resize = try resource.decodeIfPresent(String.self, forKey: .resize)
        typeRaw = try resource.decode(Int.self, forKey: .typeRaw)
        url = try resource.decode(String.self, forKey: .url)
        
        // Unfortunately, some earlier libraries have with & height as strings instead of integers
        width = try resource.decodeIntOrStringToInt(key: .width)
        height = try resource.decodeIntOrStringToInt(key: .height)
    }
    enum CodingKeys: String, CodingKey {
        case aspectRatio = "aspectratio"
        case bitrate
        case duration
        case height
        case mimeType = "mimetype"
        case resize
        case typeRaw = "type"
        case url
        case width
    }
}
