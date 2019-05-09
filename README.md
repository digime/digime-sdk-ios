# Digi.me SDK for iOS
The Digi.me SDK allow seamless authentication with Consent Access service, making content requests and core decryption services. For details on the API and general CA architecture - visit [Dev Support Docs](https://developers.digi.me/consent-access.html)

## Preamble
Digi.me SDK depends on digi.me app being installed to enabled user initiate authorization of requests. For detailed explanation of the Consent Acess architecture - visit [Dev Support Docs](https://developers.digi.me/consent-access.html).

## Requirements

- iOS version 10 or higher;
- XCode 8 or higher;
- iPhone 5 device or higher, iPad 4th Gen or higher, iPad Mini 2nd Gen or higher;

## Table of Contents

  * [Installation](#installation)
     * [Cocoapods](#cocoapods)
     * [Directly from source code](#directly-from-source-code)
  * [Configuring SDK usage](#configuring-sdk-usage)
     * [Obtaining your Contract ID and App ID](#obtaining-your-contract-id-and-app-id)
     * [Contract Private Key](#contract-private-key)
     * [DMEClient and SDK configuration](#dmeclient-and-sdk-configuration)
  * [Callbacks and responses](#callbacks-and-responses)
  * [Authorization](#authorization) 
     * [Handling app callback](#handling-app-callback)
     * [Delegate Calls (authorizationDelegate)](#delegate-calls-authorizationDelegate)
  * [Specifying Scope](#specifying-scope)
  * [Fetching data](#fetching-data)
  * [Fetching Accounts data](#fetching-accounts-data)
     * [Delegate Calls (downloadDelegate)](#delegate-calls-downloadDelegate)
     * [Automatic exponential backoff](#automatic-exponential-backoff)
  * [Fetched Files](#fetched-files)
  * [Decryption](#decryption)
  * [Postbox](#postbox---experimental)
  * [Example Objective-C](#example-objective-c)
  * [Example Swift](#example-swift)
  * [Migration Guide (2.4.0+)](#migration-guide-240)
  * [Digi.me App](#digime-app)


## Installation
### Cocoapods

[CocoaPods](http://cocoapods.org) is a dependency manager for Swift and Objective-C Cocoa projects. You can install it with the following command:

```bash
$ sudo gem install cocoapods
```

> CocoaPods 0.39.0+ is required to build DigiMeSDK 2.0.0+.

#### Podfile

To integrate the DigiMeSDK into your own existing Xcode project using CocoaPods, simply specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'

target 'TargetName' do
pod 'DigiMeSDK'
end
```

Navigate to the directory of your `Podfile` and run the following command:

```bash
$ pod install --repo-update
```
This will sync latest repository changes, and install the DigiMeSDK pod.

### Directly from source code

Download the [latest release](https://github.com/digime/digime-sdk-ios/releases). Extract the files from the archive, and copy `DigiMeSDK` folder into your project.

## Configuring SDK usage

### Obtaining your Contract ID and App ID

Before accessing the public APIs, a valid Contract ID needs to be registered for an App ID.
The Contract ID uniquely identifies a contract with the user that spells out what type of data you want, what you will and won't do with it, how long you will retain the data and whether you will implement the right to be forgotten.

Additionally it also specifies how the data is encrypted in transit.

To register a Consent Access contract check out [Digi.me Dev Support](https://developers.digi.me). There you can request a Contract ID and App ID to which it is bound.

### Contract Private Key
All content retrieved by the SDK is encrypted in transit using the public key bound to the certificate that was created when the Consent Access contract was created. For the SDK to be able to decrypt content transparently matching private key must be provided (i.e. from the key pair created for contract).

Digi.me SDK accepts PKCS #12 encoded files as the default key storage format.

Digi.me SDK provides a helper method to read and extract keys from p12 files.

1. Drag and drop your `<YOUR_P12_FILENAME>.p12` anywhere in your project.

2. Make sure you add it to your build target when presented with the copy dialog.

3. It does not matter what the filename is, but the `p12` extension does.

4. Use `DMECryptoUtilities` to extract the key from the file:

```objective-c
#import "DMECryptoUtilities.h"
.
.
.
NSString *privateKeyHex = [DMECryptoUtilities privateKeyHexFromP12File:@"YOUR_P12_FILENAME" password:@"YOUR_P12_PASSWORD"];
```

> NOTE: 
> 
> `YOUR_P12_FILENAME ` is the name of your p12 file without `p12` extension. The file must be in the bundle.
> 
> `YOUR_P12_PASSWORD` is the password used to unlock the p12 file. 

### DMEClient and SDK configuration

1.
`DMEClient` is the main hub for all the interaction with the API. You need only to import the header file into your class:

```objective-c
#import "DMEClient.h"
```

And you access it through its singleton accessor:

```objective-c
[DMEClient sharedClient]
```

2.
Before you start interacting with it in your app, however - you will need to configure it with your **contractId** and **appId**:

```objective-c
[DMEClient sharedClient].appId = @"YOUR_APP_ID";
[DMEClient sharedClient].contractId = @"YOUR_CONTRACT_ID";
```

> NOTE: 
> 
> `YOUR_APP_ID` is the App ID issued to you by Digi.me Ltd.
> 
> `YOUR_CONTRACT_ID` is the Contract ID issued to you by Digi.me Ltd. 


3.
Set the private key hex - [See above for details](#contract-private-key):

```objective-c
[DMEClient sharedClient].privateKeyHex = privateKeyHex;
```


4.
Whitelist the Digi.me app in your `Info.plist` so you can use iOS Custom URL Scheme to call digi.me client app from your application.

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
<string>digime-ca-master</string>
</array>
```

5.
Extend your `Info.plist` to support a new Custom URL Scheme. This scheme is used to return the user back to your application once they have actioned the Contract within Digi.me App.

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
> NOTE: `YOUR_APP_ID` is the App ID given to you by Digi.me Ltd.


## Callbacks and responses
 
Digi.me SDK is built to be asynchronous and thread-safe and as such it provides a couple of mechanisms of redirecting results back to the application.
For that purpose the SDK provides **DMEClientCallbacks** block based interface and **DMEClientAuthorizationDelegate** / **DMEClientDownloadDelegate** delegate based interfaces. 

> NOTE:
> Both of them are interchangeable and can be used depending on preference. 
Although they could be used both at the same time, we recommend that you use only 1 for a particular operation.


Each method that returns data has an alternative name which accepts a completion block:

```objective-c
- (void)authorize;
- (void)authorizeWithCompletion:(AuthorizationCompletionBlock)authorizationCompletion;

```

If you wish to use the delegate pattern, simply set the `DMEClient`'s `authorizationDelegate` and/or `downloadDelegate` property:

```objective-c
[DMEClient sharedClient].authorizationDelegate = self;
[DMEClient sharedClient].downloadDelegate = self;
```

> NOTE: Make sure you declare that your class implements `DMEClientAuthorizationDelegate` / `DMEClientDownloadDelegate`.
 

## Authorization

To start fetching data into your application, you will need to authorize a session.
Authorization flow is separated into two phases:

1. Initialize a session with Digi.me API (returns a **CASession** object).

2. Authorize session with the Digi.me app and prepare data if user accepts.

SDK starts and handles these steps automatically by calling:

```objective-c
[[DMEClient sharedClient] authorize];

```

> Or 
> ```
> [[DMEClient sharedClient] authorizeWithCompletion:^(CASession * _Nullable session, NSError * _Nullable error){...}];
> ```
> if not using a delegate.

## Guest Consent

If Guest Consent component is added to the project by using SDK's subfolder in the pod file:

```ruby
pod 'DigiMeSDK/GuestConsent'
```

then on `authorizeGuest` method user will be offered additional choice in the UI for your end user to choose between two options if digi.me client app is not installed on the device:
- "Install digi.me app from appstore" - this prompts your user to install the digi.me app and passes the consent session over so that your user can consent to share after creating their digi.me
- "Share as a guest" - opens a browserview and starts a single consent session. Once complete the browserview closes and the sdk retrieves the consented data.

### Handling app callback

Since `authorize` automatically opens Digi.me app, you will need some way of handling the switch back to your app. You will accomplish this by overriding the following method in your Application's Delegate (typically AppDelegate):

```objective-c
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return [[DMEClient sharedClient] openURL:url options:options];
}

```

### Delegate Calls (authorizationDelegate)

##### DMEClientAuthorizationDelegate

The following delegate methods can be implemented for the authorize stage:

```objective-c

/**
 Executed when session has been created.

 @param session Consent Access Session
 */
- (void)sessionCreated:(CASession *)session;


/**
 Executed when session creation has failed.

 @param error NSError
 */
- (void)sessionCreateFailed:(NSError *)error;


/**
 Executed when CA Contract has been successfully authorized.

 @param session Consent Access Session
 */
- (void)authorizeSucceeded:(CASession *)session;


/**
 Executed when CA Contract has been declined by the user.

 @param error NSError
 */
- (void)authorizeDenied:(NSError *)error;


/**
 Executed when CA Contract has been authorized, but failed for another reason.

 @param error NSError
 */
- (void)authorizeFailed:(NSError *)error;


```

## Specifying Scope
Specifying a scope via `CAScope` object will allow you to retrieve only a subset of data that the contract has asked for. This might come in handy if you already have data from the existing user and you might only want to retrieve any new data that might have been added to the user's library in the last x months. 

SDK currently only supports specifying scope for `CATimeRange`s.
 
The format of CATimeRange is as follows:

```objective-c
@interface CATimeRange : NSObject
@property (nonatomic, strong, readonly, nullable) NSDate *from;
@property (nonatomic, strong, readonly, nullable) NSDate *to;
@property (nonatomic, strong, readonly, nullable) NSString *last;

+ (CATimeRange *)from:(NSDate *)from;
+ (CATimeRange *)priorTo:(NSDate *)priorTo;
+ (CATimeRange *)from:(NSDate *)from to:(NSDate *)to;
+ (CATimeRange *)last:(NSUInteger)x unit:(CATimeRangeUnit)unit;
@end
```

`from` - If this is set, we will return data created after this date.

`to` - If this is set, we will return data created before this timestamp.

`last` - You can set a dynamic time range based on the current date. The string is in the format of `x<unit>`, where `x` specifies a number and `<unit>` specifies the range unit. For example, if you wanted to get the last 6 month, you would set the `last` property to `6m`.

`CATimeRange` has handy initializers you can use to cover most use cases.

Example usage:

```objective-c

CAScope *scope = [CAScope new];

//last 10 days
CATimeRange *timeRange = [CATimeRange last:10 unit:CATimeRangeUnitDay];

scope.timeRanges = @[timeRange];
[[DMEClient sharedClient] authorizeWithScope:scope];

```

## Fetching data

Upon successful authorization you can request user's files. 
To fetch the list of available files for your contract:

```objective-c
[[DMEClient sharedClient] getFileList];

```

> Or 
> ```
> [[DMEClient sharedClient] getFileListWithCompletion:^(CAFiles * _Nullable files, NSError  * _Nullable error){...}];
> ```
> if not using a delegate.
 

Upon success `DMEClient` returns a `CAFiles` object which contains a single field - `fileIds` (NSArray<NSString>), a list of file IDs.

Finally you can use the returned file IDs to fetch their data:

```objective-c
[[DMEClient sharedClient] getFileWithId:fileId];

```

> Or 
> ```
> [[DMEClient sharedClient] getFileWithId:fileId completion:^(CAFile * _Nullable file, NSError * _Nullable error){...}];
> ```
> if not using a delegate.


### Fetching Accounts Data
Additionally, you can also request to get account information for a user. This will return all accounts that data belongs to, which will contain service names, account identifiers and logos (of applicable).

To fetch accounts data:

```objective-c
[[DMEClient sharedClient] getAccounts];
```

> Or
> 
> ```objective-c
> [[DMEClient sharedClient] getAccountsWithCompletion:(CAAccounts * _Nullable accounts, NSError * _Nullable error){ ... }];
> ```


### Delegate Calls (downloadDelegate)
##### DMEClientDownloadDelegate

The following delegate methods can be implemented for the fetching stage:

```objective-c

/**
 Executed when DMEClient has retrieved file list available for the contract.

 @param files CAFiles.
 */
- (void)clientRetrievedFileList:(CAFiles *)files;


/**
 Executed DMEClient failed to retrieve contract file list.

 @param error NSError.
 */
- (void)clientFailedToRetrieveFileList:(NSError *)error;


/**
 Executed when file content has been retrieved.

 @param file CAFile object.
 */
- (void)fileRetrieved:(CAFile *)file;


/**
 Executed when file could not be retrieved

 @param fileId Id of the file that failed
 @param error NSError
 */
- (void)fileRetrieveFailed:(NSString *)fileId error:(NSError *)error;

/**
Executed when DMEClient has retrieved accounts available for the contract

@param accounts available accounts
*/
- (void)accountsRetrieved:(CAAccounts *)accounts;


/**
Executed when accounts could not be retrieved

@param error error NSError
*/
- (void)accountsRetrieveFailed:(NSError *)error;

```

### Automatic exponential backoff

Due to asynchronous nature of Consent Access architecture, it is possible for the CA services to return the `404` HTTP response. `404` errors in this context indicate that **"File is not ready"**. In other words CA services have yet to finish copying and encrypting the content for your created session.


Digi.me SDK handles those errors internally and retries those requests with exponential backoff policy. The defaults are set to 5 retries with base interval of 750ms.

> In the event that content is not ready even after retrying, SDK will return an `NSError` object to appropriate completionBlock/delegate.


These settings can be customized by creating your own `DMEClientConfiguration` object, and setting it in the `DMEClient`:

```objective-c
DMEClientConfiguration *config = [DMEClientConfiguration new];

...

[DMEClient sharedClient].clientConfiguration = config;

```

The following properties can be configured:

```objective-c
/**
 Connection time out in seconds. Defaults to 25.
 */
@property (nonatomic) NSTimeInterval globalTimeout;


/**
 Controls API retries. Default to YES.
 */
@property (nonatomic) BOOL retryOnFail;


/**
 Delay in milliseconds before retrying failed request. Defaults to 750.
 */
@property (nonatomic) NSInteger retryDelay;


/**
 Controls whether retries occur with delay. Defaults to YES.
 */
@property (nonatomic) BOOL retryWithExponentialBackOff;


/**
 Maximum number of retries before failing. Defaults to 5.
 */
@property (nonatomic) NSInteger maxRetryCount;


/**
 Maximum concurrent network operations. Defaults to 5.
 */
@property (nonatomic) NSInteger maxConcurrentRequests;


/**
 Determines whether additional SDK DEBUG logging is enabled. Defaults to NO.
 */
@property (nonatomic) BOOL debugLogEnabled;

```

## Fetched Files

Each file you fetch from Consent Access is represented by `CAFile` object. 

You can access serialized json content (NSArray) of the entire file using the following property on the `CAFile`:

```objective-c
@property (nullable, nonatomic, strong, readonly) NSArray *json;

```

For more details about JSON object formats, please see [this guide](http://developers.digi.me/reference-objects)

## Decryption
There are no additional steps necessary to decrypt the data, the SDK handles the decryption and cryptography management behind the scenes.


## Postbox - EXPERIMENTAL

**This functionality is part of an experimental API and is NOT officially supported in production yet! Please contact us for more information.**

The SDK may also be used effectively in reverse, to send data to a user's digi.me library. This feature is known as Postbox. To use Postbox, you must first request consent from the user to send data to their library. This is done via a consent contract, similarly to receiving data. If consent is given, digi.me will callback to your app, similarly to consent access, with a postbox ID and session key. You may then use a RESTful interface to send data, normalised to our standards, to a user's 'Postbox'.

As with our other APIs, there are 2 means to handle callbacks from the creation of a Postbox. The use of a block on the create method, or via a delegate. The method signatures are as follows:

```objective-c
- (void)createPostbox;
- (void)createPostboxWithCompletion:(PostboxCreationCompletionBlock)completion;
```

The respective delegate callbacks look like this:

```objective-c
- (void)postboxCreationSucceeded:(CAPostbox *)postbox;
- (void)postboxCreationFailed:(NSError *)error;
```

Once a user has authorized your Postbox request, you can use the following endpoint to 'post' data to the 'Postbox':

`POST https://api.digi.me/v1.3/permission-access/postbox/<POSTBOX_ID>`

You should provide the session key received from the SDK as a header:

`sessionKey: <CA_SESSION_KEY>`

The body of the request should be JSON in the following structure:

```json
{
    "symmetricalKey": <BASE64_ENCODED_ENCRYPTION_KEY>,
    "iv": <BASE16_ENCODED_ENCRYPTION_INITIALIZATION_VECTOR>,
    "content": <BASE64_ENCODED_CONTENT>
}
```

The content should be normalised to the format we expect. You can find more info on this in our [developer docs](https://developers.digi.me). This data should then be encrypted using AES256.

If your submission is successful, you will receive a `200 OK` from our API. If not, you will receive a detailed error message with guidence on what needs addressing.

When a user next open's digi.me, we will check your Postbox for any new data. If data is found, we'll parse it into our internal data structure and import it into the user's library.

If data is left in the Postbox for more than 7 days without import, it will be flushed.

## Example Objective-C
To see SDK in action in an Objective-C project:

1. Follow above steps to request App ID, and p12 password from Digi.me Ltd

	> Contract ID from Digi.me, p12 file are already provided in the Example app.

2. Copy this repository and open `Example/DigiMeSDKExample.xcworkspace`

3. Open `ViewController.m`

4. in `viewDidLoad` find these lines, and follow instruction in the comments:

```objective-c
// - GET STARTED -
    
// - INSERT your App ID here -
    self.dmeClient.appId = @"YOUR_APP_ID";
    
// - REPLACE 'YOUR_P12_PASSWORD' with password provided by Digi.me Ltd
    self.dmeClient.privateKeyHex = [DMECryptoUtilities privateKeyHexFromP12File:@"CA_RSA_PRIVATE_KEY" password:@"YOUR_P12_PASSWORD"];

```

5. Open up Info.plist and replace the `digime-ca-YOUR_APP_ID` value found under `CFBundleURLTypes`->`Consent Access` key.

The `YOUR_APP_ID` part is the App Id you requested from Digi.me Ltd.
For Example, if your AppID is `7hgUT835HFYhtgweh35`, 
it would look like

```xml
...
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLName</key>
			<string>Consent Access</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>digime-ca-7hgUT835HFYhtgweh35</string>
			</array>
		</dict>
	</array>
...
```

6. Build and run.

> NOTE: you will need to have Digi.me app installed and onboarded.


## Example Swift
To see SDK in action in a Swift project:

1. Follow above steps to request App ID, and p12 password from Digi.me Ltd

	> Contract ID from Digi.me, p12 file are already provided in the Example app.

2. Copy this repository and open `ExampleSwift/DigiMeSDKExampleSwift.xcworkspace`

3. Open `ViewController.swift`

4. in `viewDidLoad` find these lines, and follow instruction in the comments:

```swift
// - GET STARTED -
    
// - INSERT your App ID here -
    
dmeClient.appId = "YOUR_APP_ID"
    
// - REPLACE 'YOUR_P12_PASSWORD' with password provided by Digi.me Ltd
    
dmeClient.privateKeyHex = DMECryptoUtilities.privateKeyHex(fromP12File: "CA_RSA_PRIVATE_KEY", password: "YOUR_P12_PASSWORD")

```

5. Open up Info.plist, and replace the `digime-ca-YOUR_APP_ID` value found under `CFBundleURLTypes`->`Consent Access` key. 

The `YOUR_APP_ID` part is the App Id you requested from Digi.me Ltd.
For Example, if your AppID is `7hgUT835HFYhtgweh35`, 
it would look like

```xml
...
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLName</key>
			<string>Consent Access</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>digime-ca-7hgUT835HFYhtgweh35</string>
			</array>
		</dict>
	</array>
...
```

6. Build and run.

> NOTE: you will need to have Digi.me app installed and onboarded.

## Migration Guide (2.4.0+)
Follow these steps if you are migrating existing implementation of `DigiMeSDK` to `DigiMeSDK` v2.4.0+.
	
#### SDK Delegate

##### Change Interface declaration to use new delegate:

From:

```objective-c
@interface <YourClass> (DMEClientDelegate)
...
@end
```

To:

```objective-c
@interface <YourClass> (DMEClientAuthorizationDelegate, DMEClientDownloadDelegate)
...
@end
```

##### Change delegate assignment.

From:

```objective-c
[DigiMeFramework sharedInstance].delegate = self;
```

To:

```objective-c
[DMEClient sharedClient].authorizationDelegate = self;
[DMEClient sharedClient].downloadDelegate = self;
```


Implement delegates described in [Authorize](#delegate-calls-authorize) and [Fetching Data](#delegate-calls-fetching) sections.


## Digi.me App

Digi.me for iOS is the main hub for giving permission to download an individual's data to your app. Digi.me for iOS will show the individual the contract details and provide a preview of the data that will be shared. The individual must consent to sharing the data. [Download digi.me for iOS here](https://itunes.apple.com/us/app/digi-me/id1234541790)


##
Copyright © 2019 digi.me Ltd. All rights reserved.



