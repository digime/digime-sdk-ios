
# Migration Tips
Here are some key SDK changes that may help you get to grips with it if you are migrating from previous versions:

1. `DMEClient` singleton no longer exists. It has been replaced by `DMEPullClient` and `DMEPushClient`.

2. 

3. Each type of client has to be instantiated with a corresponding configuration object:

	```objective-c
DMEPullConfiguration *pullConfig = [[DMEPullConfiguration alloc] initWithAppId:@"your_app_id" contractId:@"your_contract_id" p12FileName:@"p12_filename" p12Password:@"p12_password"];
DMEPullClient *pullClient = [[DMEPullClient alloc] initWithConfiguration:pullConfig];
	```

4. We recommend you turn on debug logging while evaluating the SDK, which can be done via:

	```objective-c
	// this will add extra logging to the console.
	pullConfig.debugLogEnabled = YES;
	```
5. We no longer support delegate based approach for SDK callbacks. Alternatives are:

	```objective-c
	//Begin auth flow
	[pullClient authorizeWithCompletion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        
        // if there's no error - you can now get accounts
        // and/or start downloading session data
    }];
	```
	```objective-c
	//get accounts
	[pullClient getSessionAccountsWithCompletion:^(DMEAccounts * _Nullable accounts, NSError * _Nullable error) {
		// do stuff
	}];
	```
	```objective-c
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

## Issues
For any issues, please contact us via digi.me-api slack.