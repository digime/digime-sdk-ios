![](https://securedownloads.digi.me/partners/digime/SDKReadmeBanner.png)

<p align="center">
    <a href="https://developers.digi.me/slack/join">
        <img src="https://img.shields.io/badge/chat-slack-blueviolet.svg" alt="Developer Chat">
    </a>
    <a href="LICENSE">
        <img src="https://img.shields.io/badge/license-apache 2.0-blue.svg" alt="MIT License">
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

# Migration Tips
Here are some key SDK changes that may help you get to grips with it if you are migrating from previous versions:

1. `DMEClient` singleton no longer exists. It has been replaced by `DMEPullClient` and `DMEPushClient`.

2. In `AppDelegate`, you still need to forward app open events to the SDK. This is now done by forwarding the event to `DMEAppCommunicator`:

```objc
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
	return [[DMEAppCommunicator shared] openURL:url options:options];
}
```

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
  return DMEAppCommunicator.shared().open(url, options: options)
}
```

3. Each type of client has to be instantiated with a corresponding configuration object:

```objc
DMEPullConfiguration *configuration = [[DMEPullConfiguration alloc] initWithAppId:@"YOUR_APP_ID" contractId:@"YOUR_CONTRACT_ID" privateKeyHex: privateKeyHex];
DMEPullClient *pullClient = [[DMEPullClient alloc] initWithConfiguration:configuration];
```

```swift
let configuration = DMEPullConfiguration(appId: "YOUR_APP_ID", contractId: "YOUR_CONTRACT_ID", privateKeyHex: privateKeyHex)
let pullClient = DMEPullClient(configuration: configuration)
```

4. We recommend you turn on debug logging while evaluating the SDK, which can be done via:

```objc
// this will add extra logging to the console.
configuration.debugLogEnabled = YES;
```

```swift
// this will add extra logging to the console.
configuration.debugLogEnabled = true
```

5. We no longer support delegate based approach for SDK callbacks. Alternatives are:

```objc
//Begin auth flow
[pullClient authorizeWithCompletion:^(DMESession * _Nullable session, NSError * _Nullable error) {

  // if there's no error - you can now get accounts
  // and/or start downloading session data
}];
```

```swift
//Begin auth flow
pullClient.authorize(completion: { session, error in

  // if there's no error - you can now get accounts
  // and/or start downloading session data
})
```

```objc
//get accounts
[pullClient getSessionAccountsWithCompletion:^(DMEAccounts * _Nullable accounts, NSError * _Nullable error) {
	// do stuff
}];
```

```swift
//get accounts
pullClient.getSessionAccounts { accounts, error in
	// do stuff
}
```

```objc
//get session data
//NOTE: downloadHandler and completion are NOT executed on MAIN thread.
[pullClient getSessionDataWithDownloadHandler:^(DMEFile * _Nullable file, NSError * _Nullable error) {
  // this is called every time either:
  // A: new file has been downloaded
  // B: prevously downloaded file has been updated
  // In case B, full file is delivered NOT the change.
} completion:^(NSError * _Nullable error) {
  // this is called when all available session data has been retrieved.
}];
```

```swift
//get session data
//NOTE: downloadHandler and completion are NOT executed on MAIN thread.
pullClient.getSessionData(downloadHandler: { file, error in
  // this is called every time either:
  // A: new file has been downloaded
  // B: prevously downloaded file has been updated
  // In case B, full file is delivered NOT the change.
}, completion: { error in
  // this is called when all available session data has been retrieved.
})
```
