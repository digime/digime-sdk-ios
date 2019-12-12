![](https://securedownloads.digi.me/partners/digime/SDKReadmeBanner.png)

<p align="center">
    <a href="https://developers.digi.me/slack/join">
        <img src="https://img.shields.io/badge/chat-slack-blueviolet.svg" alt="Developer Chat">
    </a>
    <a href="https://github.com/digime/digime-sdk-ios/blob/master/LICENSE">
        <img src="https://img.shields.io/badge/license-apache 2.0-blue.svg" alt="Apache 2.0 License">
    </a>
    <a href="#">
    	<img src="https://img.shields.io/badge/build-passing-brightgreen.svg">
    </a>
    <a href="https://swift.org">
        <img src="https://img.shields.io/badge/language-objectivec/swift-orange.svg" alt="Objective-C/Swift">
    </a>
    <a href="https://developers.digi.me">
        <img src="https://img.shields.io/badge/web-digi.me-red.svg" alt="Web">
    </a>
    <a href="https://digime.freshdesk.com/support/solutions/9000115894">
        <img src="https://img.shields.io/badge/support-freshdesk-721744.svg" alt="Support">
    </a>
</p>

<br>

# Limiting Scope

Sometimes you may only want to retrieve a subset of data. This is governed at two levels. At the top are any scope limitations dictated by your contract; these can only be changed by digi.me support so please [contact support](https://developers.digi.me/contact-us) if you want to discuss this further.

At a code level, you can restrict the scope of a Private Sharing session by passing in a custom `DMEScope`.

## Defining `DMEScope`

`DMEScope` is comprised of three properties. `timeRanges` is a list of `DMETimeRange` objects (more on this below) to limit the breadth of time for which applicable data will be returned. `serviceGroups` is a list of `DMEServiceGroup` objects, which nests it's own list of `DMEServiceType` objects, nesting `DMEObjectType` objects; this is also detailed below. `context` is set automatically and cannot be overridden.

### _Scoping by time range_:

`DMETimeRange` has 3 properties. `fromDate`, `toDate` and `last`. These are all optional but **at least one is required.**

We recommend you use one of the convenience methods provided:

```objc
//  A valid NSDate object representation of the earliest date you want data for.
+ (DMETimeRange *)from:(NSDate *)from;

// A valid NSDate object representation of the date before which you would like data.
+ (DMETimeRange *)priorTo:(NSDate *)priorTo;

// A valid NSDate object representation of the start / end periods for which you want data for.
+ (DMETimeRange *)from:(NSDate *)from to:(NSDate *)to;

// An integer an a unit to describe date period you want the data for. Unit may be days, month or years
+ (DMETimeRange *)last:(NSUInteger)x unit:(DMETimeRangeUnit)unit;
```

### _Scoping by service group, service type or object type:_

To restrict scope at an object level, your scope must be 'fully described'; that is to say that a service group must comprise at least one service type, which must comprise at least one object type. Furthermore, a service group may only contain service types belonging to it and said service types may only contain object types belonging to them.

Service Groups, Service Types and Objects are all listed [here](https://developers.digi.me/reference-objects) in the developer documentation. Their relationships are also shown (what belongs to what).

Below is an example of a valid scope to retrive only `Playlists` and `Followed Artists` from `Spotify`:

#####Objective-C
```objc
DMEServiceObjectType * playlistObjectType = [[DMEServiceObjectType alloc] initWithIdentifier:403]; // 403 is the ID for a Playlist object.
DMEServiceObjectType * followedArtistObjectType = [[DMEServiceObjectType alloc] initWithIdentifier:407]; // 407 is the ID for a Followed Artist object.
    
DMEServiceType *spotifyServiceType = [[DMEServiceType alloc] initWithIdentifier:19 objectTypes:@[playlistObjectType, followedArtistObjectType]]; // 19 is the ID for Spotify.
    
DMEServiceGroup * entertainmentServiceGroup = [[DMEServiceGroup alloc] initWithIdentifier:5 serviceTypes:@[spotifyServiceType]]; // 5 is the ID for Entertainment.
    
//create scope object
DMEScope *scope = [DMEScope new]; // This scope is valid, as no restrictions have been imposed.
scope.serviceGroups = @[entertainmentServiceGroup]; // The scope is still valid, as it conforms to the rules listed above.
```

#####Swift
```swift
let playlistObjectType = DMEServiceObjectType(identifier: 403) // 403 is the ID for a Playlist object.
let followedArtistObjectType = DMEServiceObjectType(identifier: 407) // 407 is the ID for a Followed Artist object.

let spotifyServiceType = DMEServiceType(identifier: 19, objectTypes: [playlistObjectType, followedArtistObjectType]) // 19 is the ID for Spotify.

let entertainmentServiceGroup = DMEServiceGroup(identifier: 5, serviceTypes: [spotifyServiceType]) // 5 is the ID for Entertainment.

let scope = DMEScope() // This scope is valid, as no restrictions have been imposed.
scope.serviceGroups = [entertainmentServiceGroup] // The scope is still valid, as it conforms to the rules listed above.
```


## Providing `DMEScope`

When calling `authorize` on your `DMEPullClient`, simply pass in your `DMEScope` object:

#####Objective-C
```objc
DMEScope *scope = [DMEScope new];
scope.timeRanges = @[[DMETimeRange last:6 unit:DMETimeRangeUnitMonth]];
[pullClient authorizeWithScope:scope completion:^(DMESession * _Nullable session, NSError * _Nullable error) {

}];
```

#####Swift
```swift
let scope = DMEScope()
scope.timeRanges = [DMETimeRange.last(6, unit: .month)]
pullClient.authorize(scope: scope, completion: { session, error in

})
```

The data received from any subsequent calls to `getSessionData` will be limited by the scope of the session defined above.
