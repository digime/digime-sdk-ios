//
//  PostType.swift
//  DigiMeSDK
//
//  Created on 26/10/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

@objc public enum PostType: Int {
    case standard = 0
    case facebookStatusUpdate = 1
    case facebookWallPost = 2
    case facebookNote = 3
    case twitterTweet = 4
    case twitterMention = 5
    case twitterFavourite = 6
    case twitterFavouriteAndTweet = 15
    case twitterFavouriteAndMention = 16
    case twitterMentionAndTweet = 17
    case twitterFavouriteAndMentionAndTweet = 18
    case flickrPost = 19
    case instagramPost = 20
    case flickrPostFavourite = 21
    case facebookInternalPost = 22
    case facebookGroupPost = 23
    case pinterestPin = 24
    case pinterestLike = 25
}
