![](https://i.imgur.com/zAHoOwe.png)

<p align="center">
    <a href="https://developers.digi.me/slack/join">
        <img src="https://img.shields.io/badge/chat-slack-blueviolet.svg" alt="Developer Chat">
    </a>
    <a href="LICENSE">
        <img src="https://img.shields.io/badge/license-apache 2.0-blue.svg" alt="MIT License">
    </a>
    <a href="#">
    	<img src="https://img.shields.io/badge/build-passing-brightgreen.svg" 
    </a>
    <a href="https://swift.org">
        <img src="https://img.shields.io/badge/language-objectivec/swift-orange.svg" alt="Objective-C/Swift">
    </a>
    <a href="https://developer.digi.me">
        <img src="https://img.shields.io/badge/web-digi.me-red.svg" alt="Web">
    </a>
</p>

<br>

# Postbox

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

### 2. Configuring Callback Forwarding:

Because the digi.me Private Sharing SDK opens the digi.me app for authorization, you are required to forward the `openURL` event through to the SDK so that it may process responses. In your application's delegate (typically `AppDelegate`) override `application:openURL:options:` method as below:

```objc
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
	return [[DMEAppCommunicator shared] openURL:url options:options];
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

The `DMEPushConfiguration` object is instantiated with your `AppID` and `Private Key` in hex format. The below code snippet shows you how to combine all this to get a configured `DMEPushClient`:

```objc
DMEPushConfiguration *configuration = [[DMEPushConfiguration alloc] initWithAppId:@"your-app-id" contractId:@"your-contract-id"];
DMEPushClient *pushClient = [[DMEPushClient alloc] initWithConfiguration:configuration];
```

### 4. Requesting Consent:

Before you can push data into a user's digi.me, you must obtain their consent. This is achieved by calling `createPostbox` on your client object:

```objc
[pushClient createPostboxWithCompletion::^(DMEPostbox * _Nullable postbox, NSError * _Nullable error) {
	
}
```

If a user grants consent, a Postbox will be created and returned; this is used by subsequent calls to push data. If the user denies consent, an error stating this is returned. See [Handling Errors](error-handling.html).

### 5. Pushing Data:

To push data, you need to build a JSON `metadata` object that describes what data your pushing along with the NSData representation of your data itself. An example showing Postbox creation and push can be seen below.:

```objc
NSData data = ... // Obtain the data you wish to post.
NSData metadata = ... // All Postbox submissions must be pushed with appropriate metadata. See the example apps for more details.

[pushClient pushDataToPostbox:postbox metadata:metadata data:data completion:^(NSError * _Nullable error) {
    // Handle error, if any.
}];
```

*NB: Please refer to our Postbox example in the [Swift Example App](https://github.com/digime/digime-sdk-ios/tree/master/ExampleSwift) for more details on data and metadata.*