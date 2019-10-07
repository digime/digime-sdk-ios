![](https://i.imgur.com/zAHoOwe.png)

<p align="center">
    <a href="https://digime-api.slack.com/">
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
    <a href="https://twitter.com/codevapor">
        <img src="https://img.shields.io/badge/web-digi.me-red.svg" alt="Web">
    </a>
</p>

<br>

# Migration Tips
Here are some key SDK changes that may help you get to grips with it if you are migrating from previous versions:

1. `DMEClient` singleton no longer exists. It has been replaced by `DMEPullClient` and `DMEPushClient`.

2. In `AppDelegate`, you still need to forward app open events to the SDK. This is now done by forwarding the event to `DMEAppCommunicator`:
3. 
	```objc
	-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    	return [[DMEAppCommunicator shared] openURL:url options:options];
}
	``` 

3. Each type of client has to be instantiated with a corresponding configuration object:

	```objc
DMEPullConfiguration *pullConfig = [[DMEPullConfiguration alloc] initWithAppId:@"your_app_id" contractId:@"your_contract_id" p12FileName:@"p12_filename" p12Password:@"p12_password"];
DMEPullClient *pullClient = [[DMEPullClient alloc] initWithConfiguration:pullConfig];
	```

4. We recommend you turn on debug logging while evaluating the SDK, which can be done via:

	```objc
	// this will add extra logging to the console.
	pullConfig.debugLogEnabled = YES;
	```
5. We no longer support delegate based approach for SDK callbacks. Alternatives are:

	```objc
	//Begin auth flow
	[pullClient authorizeWithCompletion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        
        // if there's no error - you can now get accounts
        // and/or start downloading session data
    }];
	```
	```objc
	//get accounts
	[pullClient getSessionAccountsWithCompletion:^(DMEAccounts * _Nullable accounts, NSError * _Nullable error) {
		// do stuff
	}];
	```
	```objc
	//get session data
	//NOTE: downloadHandler and completion are NOT executed on MAIN thread.
	[self.dmeClient getSessionDataWithDownloadHandler:^(DMEFile * _Nullable file, NSError * _Nullable error) {
        // this is called every time either:
        // A: new file has been downloaded
        // B: prevously downloaded file has been updated
        // In case B, full file is delivered NOT the change.
    } completion:^(NSError * _Nullable error) {
        // this is called when all available session data has been retrieved.
    }];
	```