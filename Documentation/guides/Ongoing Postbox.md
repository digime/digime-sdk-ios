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

# Ongoing Postbox


## Introduction

An Ongoing Postbox allows your app to push data to the user over multiple app sessions without the use of digi.me app **after** initial consent has been given*.

From developer perspective the authorization process is almost identical to regular authorization. Under the hood we use OAuth 2.0 with JWT and JWS with RSA signing and verification to issue a medium lived, refreshable OAuth token, which is used to re-query user's data without the need to leave your app.

Here is a simplified sequence diagram of how the OAuth flow is implemented:
![](https://securedownloads.digi.me/partners/digime/OngoingAccess.png)

*The SDK handles all of this for you.*

Ongoing Access is for you if:

* You need to regularly push data to your user
* You are using an ongoing push contract

\* *`refreshTokens` used to refresh `accessTokens` do eventually expire (for example - 30 days). When this happens, user will need to be directed back to digi.me app for re-authorization.*



## Example
Please refer to our Ongoing Postbox example in the [Swift Example App](https://github.com/digime/digime-sdk-ios/tree/master/ExampleSwift) for more details on data and metadata.


## How to use

### Create Ongoing Postbox

Simply use the new `authorizeOngoingPostbox` method on an instance of `DMEPushClient`:

#####Objective-c
```objc
[pushClient authorizeOngoingPostboxWithExistingPostbox:nil completion:^(DMEOngoingPostbox * _Nullable postbox, NSError * _Nullable error) {
	// You may now push data to the postbox
}];
```


#####Swift
```swift
pushClient.authorizeOngoingPostbox(withExisting: nil, completion: { postbox, error in
	// You may now push data to the postbox
})
```

You may notice that upon completion of this method, the SDK supplies a `DMEOngoingPostbox` which contains the postbox identifier and an OAuth token.  This is **key** to restoring access to the Ongoing Postbox and we recommend you store this - you will need it later.

Our recommendation would be to save it to keychain.

### Refreshing Ongoing Postbox

If you have previously obtained user's consent, and are in possession of a `DMEOngoingPostbox`, you can push data to your users without them having to leave your app.

To do this, simply call the following method on a **new** `DMEPushClient` instance:

#####Objective-c
```objc
[pushClient authorizeOngoingPostboxWithExistingPostbox: myOngoingPostbox completion:^(DMEOngoingPostbox * _Nullable postbox, NSError * _Nullable error) {
	// You may now push data to the postbox
}];
```


#####Swift
```swift
pushClient.authorizeOngoingPostbox(withExisting: myOngoingPostbox, completion: { postbox, error in
	// You may now push data to the postbox
})
```

It is important to replace your existing Ongoing Postbox with the one returned in the completion block as this may contain an updated session key which will be required to push data.

### Push Data to Ongoing Postbox

There is a new function in `DMEPushClient` dedicated to pushing to an Ongoing Postbox:

#####Objective-c
```objc
[pushClient pushDataToOngoingPostbox:myOngoingPostbox metdata:myMetadata data:myData completion :^(DMEOngoingPostbox * _Nullable postbox, NSError * _Nullable error) {
	// Handle error or store updated Ongoing Postbox
}];
```


#####Swift
```swift
pushData(to: myOngoingPostbox, metadata: myMetadata, data: myData, completion: { updatedPostbox, error in
	// Handle error or store updated Ongoing Postbox
})
```

It is important to replace your existing Ongoing Postbox with the one returned in the completion block as it may contain an updated OAuth token.

This is because the SDK will try to automatically refresh an `accessToken` using a `refreshToken`, if necessary, (both of these contained in `DMEOAuthToken` in the `DMEOngoingPostbox`), generating a new `DMEOAuthToken`.


#### Configuration Options
There is a new property available on `DMEPushConfiguration` object - `autoRecoverExpiredCredentials`. This defaults to `true`, which means that if the `refreshToken` contained in `DMEOAuthToken` has expired, the user will be directed to the digi.me app, so that this can be regenerated.

If you wish to direct the user back to digi.me app manually, set this property to:

#####Objective-c
```objc
configuration.autoRecoverExpiredCredentials = NO;
```
#####Swift
```swift
configuration.autoRecoverExpiredCredentials = false;
```
When set to `false`, the SDK will return an `AuthErrorOAuthTokenExpired` error in completion.

### Anything else?

If you need help setting up the rest of the flow, or simply more detail, then head on over to [Getting Started](getting-started.html).
