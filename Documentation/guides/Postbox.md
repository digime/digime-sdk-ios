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

# Postbox

<hr>
**This SDK feature is for evaluation purposes only.**

Please get in touch if you are interested in using it in a live product solution by emailing [support@digi.me](mailto:support@digi.me) and we can discuss your requirements and the suitability of Postbox within your solution.
<hr>

## Introduction

digi.me is a data portability facilitator. As such, we support the flow of data in both directions - from the user to you, and from you back to the user. This process of 'giving data back' is known as Postbox and will henceforth be referred to as such.

Instances may arise where you wish to utilise data not currently supported by digi.me natively, Postbox allows you to do this. It does what it says on the tin, acts as a postbox for data into a user's digi.me.

## Types of Push

When pushing data to Postbox you have two main options:

#### Data pre-mapped into digi.me's ontology:

digi.me publishes it's data ontology [here](https://developers.digi.me/reference-api) for the various data types. When making a submission, if you push data normalised to this format, it will be displayed in the digi.me more appropriately, with UI specifically engineered to maximise the value of that data. It also means that when you or another third party requests this data via pull, it can be included within a collection of data points of the same type.

#### Unmapped data ([Raw Data](raw-data.html)):

digi.me can also act as a vault for data that does not fit within our current ontology, whether to collate user data together in one place or to act as a conduit between a data provider and data consumer. When data that doesn't correspond to one of digi.me's object types is pushed, this will be rendered within digi.me as a raw 'data drop'. If we can deserialise this to JSON, we will show the raw JSON tree, otherwise there will be no facility to preview the data - this is for security reasons.

## Pushing Data - 5 Simple Steps

The digi.me Private Sharing SDK makes it easy to create a postbox to push data to. Similarly to requesting data, you can achieve this by utilising a client object as follows:

### 1. Obtaining your Contract ID & Application ID:

Postbox uses the same means of authentication as pulling user data.

To access the digi.me platform, you need to obtain an `AppID` for your application. You can get yours by filling out the registration form [here](https://go.digi.me/developers/register).

In a production environment, you will also be required to obtain your own `Contract ID` from digi.me support. However, for sandbox purposes, we provide the following example value:

**Example Contract ID:** `Cb1JC2tIatLfF7LH1ksmdNx4AfYPszIn`
See [Swift Example App](https://github.com/digime/digime-sdk-ios/tree/master/ExampleSwift) for private key details.

### 2. Configuring Callback Forwarding:

Because the digi.me Private Sharing SDK opens the digi.me app for authorization, you are required to forward the `openURL` event through to the SDK so that it may process responses. In your application's delegate (typically `AppDelegate`) override `application:openURL:options:` method as below:

#####Objective-C
```objc
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
	return [[DMEAppCommunicator shared] openURL:url options:options];
}
```

#####Swift
```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
  return DMEAppCommunicator.shared().open(url, options: options)
}
```

<br>
Additionally, you need to whitelist Digi.me app scheme in your `Info.plist`:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
<string>digime-ca-master</string>
</array>
```
<br>
And register custom URL scheme so that your app can receive the callback from Digi.me app. Still in `Info.plist` add:

```xml
<key>CFBundleURLTypes</key>
<array>
<dict>
<key>CFBundleTypeRole</key>
<string>Editor</string>
<key>CFBundleURLName</key>
<string>Consent Access</string>
<key>CFBundleURLSchemes</key>
<array>
<string>digime-ca-YOUR_APP_ID</string>
</array>
</dict>
</array>
```
where `YOUR_APP_ID` should be replaced with your `AppID`.

### 3. Configuring the `DMEPushClient` object:
`DMEPushClient` is the object you will primarily interface with to use the SDK. It is instantiated with a `DMEPushConfiguration` object.

The `DMEPushConfiguration` object is instantiated with your `AppID`, `ContractID` and `Private Key` in hex format. The below code snippet shows you how to combine all this to get a configured `DMEPushClient`:

#####Objective-C
```objc
DMEPushConfiguration *configuration = [[DMEPushConfiguration alloc] initWithAppId:@"YOUR_APP_ID" contractId:@"YOUR_CONTRACT_ID" privateKeyHex:@"YOUR_PRIVATE_KEY"];
DMEPushClient *pushClient = [[DMEPushClient alloc] initWithConfiguration:configuration];
```

#####Swift
```swift
let configuration = DMEPushConfiguration(appId: "YOUR_APP_ID", contractId: "YOUR_CONTRACT_ID", privateKeyHex: "YOUR_PRIVATE_KEY")
let pushClient = DMEPushClient(configuration: configuration)
```

### 4. Requesting Consent:

Before you can push data into a user's digi.me, you must obtain their consent. This is achieved by calling `createPostbox` on your client object:

#####Objective-C
```objc
[pushClient createPostboxWithCompletion:^(DMEPostbox * _Nullable postbox, NSError * _Nullable error) {

}];
```

#####Swift
```swift
pushClient.createPostbox { postbox, error in

}
```

If a user grants consent, a Postbox will be created and returned; this is used by subsequent calls to push data. If the user denies consent, an error stating this is returned. See [Handling Errors](error-handling.html).

### 5. Pushing Data:

To push data, you need to build a JSON `metadata` object that describes what data your pushing along with the NSData representation of your data itself. An example showing Postbox creation and push can be seen below.:

#####Objective-C
```objc
NSData *data = ... // Obtain the data you wish to post.
NSData *metadata = ... // All Postbox submissions must be pushed with appropriate metadata. See the example apps for more details.

[pushClient pushDataToPostbox:postbox metadata:metadata data:data completion:^(NSError * _Nullable error) {
  // Handle error, if any.
}];
```

#####Swift
```swift
let data: Data = ... // Obtain the data you wish to post.
let metadata: Data = ... // All Postbox submissions must be pushed with appropriate metadata. See the example apps for more details.

pushClient.pushData(to: postbox, metadata: metadata, data: data) { error in
  // Handle error, if any.
}
```

### 6. Multiple Data Pushes:

Multiple data pushes can be made to a postbox within
 the duration of the session. To make data pushes over mulitple app sessions, you can create a new postbox for each app session (which requires user's consent for each session).

Alternatively you can create an [Ongoing Postbox](ongoing-postbox.html), which only requires user's consent once, and store a reference to the ongoing postbox between app sessions.

*NB: Please refer to our Postbox example in the [Swift Example App](https://github.com/digime/digime-sdk-ios/tree/master/ExampleSwift) for more details on data and metadata.*
