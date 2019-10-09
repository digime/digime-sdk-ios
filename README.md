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

## Introduction

The digi.me private sharing platform empowers developers to make use of user data from thousands of sources in a way that fully respects a user's privacy, and whilst conforming to GDPR. Our consent driven solution allows you to define exactly what terms you want data by, and the user to see these completely transparently, allowing them to make an informed choice as to whether to grant consent or not.

## Requirements

### Development
- XCode 10.3 or newer.
- [CocoaPods](http://cocoapods.org) 1.7.0 or newer.

### Deployment
- iOS version (latest - 1) **\***

**\*** The SDK will run on any version of the iOS, but the digi.me app only supports latest - 1.


## Installation

### Cocoapods

1. Add `DigiMeSDK` to your `Podfile`:

	```ruby
	use_frameworks!
	source 'https://github.com/CocoaPods/Specs.git'
	platform :ios, '12.0'

	target 'TargetName' do
		pod 'DigiMeSDK'
	end
	```
> NOTE
> We do not currently support linking DigiMeSDK as a Static Library.
> 
> **use_frameworks!** flag must be set in the Podfile
	
2. Navigate to the directory of your `Podfile` and run the following command:

	```bash
	$ pod install --repo-update
	```
	
## Getting Started - 5 Simple Steps!

We have taken the most common use case for the digi.me Private Sharing SDK and compiled a quick start guide, which you can find below. Nonetheless, we implore you to [explore the documentation further](https://digime.github.io/digime-sdk-ios/index.html).

This example will show you how to configure the SDK, and get you up and running with **retrieving user data**.

### 1. Obtaining your Contract ID, Application ID & Private Key:

To access the digi.me platform, you need to obtain an `AppID` for your application. You can get yours by filling out the registration form [here](https://go.digi.me/developers/register).

In a production environment, you will also be required to obtain your own `Contract ID` and `Private Key` from digi.me support. However, for sandbox purposes, we provide the following example values:

**Example Contract ID:** `fJI8P5Z4cIhP3HawlXVvxWBrbyj5QkTF `
<br>
**Example Private Key:**
	<br>&nbsp;&nbsp;&nbsp;&nbsp;Download: [P12 Key Store](https://github.com/digime/digime-sdk-ios/blob/master/Example/fJI8P5Z4cIhP3HawlXVvxWBrbyj5QkTF.p12?raw=true)
	<br>&nbsp;&nbsp;&nbsp;&nbsp;Password: `monkey periscope`
	
You should include the P12 file in your project assets folder.

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

### 3. Configuring the `DMEPullClient` object:
`DMEPullClient` is the object you will primarily interface with to use the SDK. It is instantiated with a context, and a `DMEPullConfiguration` object. **The provided context should always be the main application context.**

The `DMEPullConfiguration` object is instantiated with your `App ID`, `Contract ID` and `Private Key` in hex format. We provide a convenience method to extract the private key. The below code snippet shows you how to combine all this to get a configured `DMEPullClient`:

```objc
NSString *privateKeyHex = [DMECryptoUtilities privateKeyHexFromP12File: p12FileName password: p12Password];
DMEPullConfiguration *configuration = [[DMEPullConfiguration alloc] initWithAppId:@"YOUR_APP_ID" contractId:@"YOUR_CONTRACT_ID" privateKeyHex: privateKeyHex];
DMEPullClient *pullClient = [[DMEPullClient alloc] initWithConfiguration:configuration];
```

### 4. Requesting Consent:

Before you can access a user's data, you must obtain their consent. This is achieved by calling `authorize` on your client object:

```objc
[pullClient authorizeWithCompletion:^(DMESession * _Nullable session, NSError * _Nullable error) {

}];
```

If a user grants consent, a session will be created and returned; this is used by subsequent calls to get data. If the user denies consent, an error stating this is returned. See [Handling Errors](https://digime.github.io/digime-sdk-ios/error-handling.html).

### 5. Fetching Data:

Once you have a session, you can request data. We strive to make this as simple as possible, so expose a single method to do so: 

```objc
[self.dmeClient getSessionDataWithDownloadHandler:^(DMEFile * _Nullable file, NSError * _Nullable error) {
        
    // Handle each downloaded file here.
        
} completion:^(NSError * _Nullable error) {

	// Any errors interupting the flow of data will be directed here, or nil once all files are retrieved.

}];
```

For each file, the first 'file handler' block will be called. If the download was successful, you will receive a `DMEFile` object. If the download fails, an error. 

Once all files are downloaded, the second block will be invoked to inform you of this. In the case that the data stream is interrupted, or if the session obtained above isn't valid (it may have expired, for example), you will receive an error in the second block. See [Handling Errors](https://digime.github.io/digime-sdk-ios/error-handling.html).

`DMEFile` exposes the method `fileContentAsJSON` which attempts to decode the binary file into a JSON map, so that you can easily extract the values you need to power your app. Not all files can be represented as JSON, see [Raw Data]() for details.

## Contributions

digi.me prides itself in offering our SDKs completely open source, under the [Apache 2.0 Licence](LICENCE); we welcome contributions from all developers.

We ask that when contributing, you ensure your changes meet our [Contribution Guidelines]() before submitting a pull request.

## Further Reading

The topics discussed under [Quick Start](getting-started---5-simple-steps) are just a small part of the power digi.me Private Sharing gives to data consumers such as yourself. We highly encourage you to explore the [Documentation](https://digime.github.io/digime-sdk-ios/index.html) for more in-depth examples and guides, as well as troubleshooting advice and showcases of the plethora of capabilities on offer.

Additionally, there are a number of example apps built on digi.me in the examples folder. Feel free to have a look at those to get an insight into the power of Private Sharing.
