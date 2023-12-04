# Scope

## Limiting Scope

Sometimes you may only want to retrieve a subset of data. This is governed at two levels. At the top are any scope limitations dictated by your contract; these can only be changed by digi.me support so please [contact support](https://developers.digi.me/contact-us) if you want to discuss this further.

At a code level, you can restrict the scope of a Private Sharing session by passing in a custom `ReadOptions` object when requesting data.

## Defining `ReadOptions`

`ReadOptions` is comprised of two properties.

* `limits` governs any limits to the data request that you'd like to impose. For example, you can limit the duration of the request should you prefer to retrieve a subset of all available data quickly, as opposed to waiting for all of the data to be resolved and returned.

* `scope` defines the scope of the data you'd like to retrieve.

## Scope

Scope has 2 properties, an array of `TimeRange` objects and an array of `ServiceGroupScope` objects.

### _Scoping by time range_:

`TimeRange` is an enum with 4 states; `after`, `between`, `before` and `last`.
These are self-explainatory and allow you to define time ranges that returned data must conform to.

### _Scoping by service group, service type or object type:_

To restrict scope at an object level, your scope must be 'fully described'; that is to say that a service group must comprise at least one service type, which must comprise at least one object type. Furthermore, a service group may only contain service types belonging to it and said service types may only contain object types belonging to them.

Service Groups, Service Types and Objects are all listed [here](https://developers.digi.me/docs) in the developer documentation. Their relationships are also shown (what belongs to what).

Below is an example of a valid scope to retrive only `Playlists` and `Followed Artists` from `Spotify`:

```swift
let playlistObjectType = ServiceObjectType(identifier: 403) // 403 is the ID for a Playlist object.
let followedArtistObjectType = ServiceObjectType(identifier: 407) // 407 is the ID for a Followed Artist object.

let spotifyServiceType = ServiceType(identifier: 19, objectTypes: [playlistObjectType, followedArtistObjectType]) // 19 is the ID for Spotify.

let entertainmentServiceGroup = ServiceGroup(identifier: 5, serviceTypes: [spotifyServiceType]) // 5 is the ID for Entertainment.

let scope = Scope(serviceGroups: [entertainmentServiceGroup])
let readOptions = ReadOptions(scope: scope)
```


## Providing `ReadOptions`

When calling `readAllFiles` on your `DigiMe` object, simply pass your `ReadOptions` object to this method:

```swift
digiMe.readAllFiles(readOptions: readOptions, ...)
```
