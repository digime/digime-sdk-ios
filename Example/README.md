# Using Example skeleton Consent Access iOS application

## Installation

- Open 'Example' folder and navigate to 'DigiMeFramework.xcworkspace' file;
- Open macOS Terminall app and change your current location to:

```bash
/.../digime-ios-sdk/Example
```
and run the following command:

```bash
$ pod install
```
-  [Ask digi.me support](http://devsupport.digi.me/) for the new contract ids and add them to the project by editing this file:

```
/.../digime-ios-sdk/Example/DigiMeFramework/Constants.swift
```
- Replace:

```swift
static let kContractID1 = ""
static let kContractID2 = ""
```
- With:
```swift
static let kContractID1 = "aYdTwM8TcWpqMRaTHiHnqoJs6ObHBbr4"
static let kContractID2 = "bapm94fEwSp8JUnm5XgeYkWTrqNgblgi"
```
- [Ask digi.me support](http://devsupport.digi.me/) for the sample private keys in p12 format and replace the existing files in the project:

```bash
/.../digime-ios-sdk/Example/DigiMeFramework/CA_RSA_PRIVATE_KEY1.p12
/.../digime-ios-sdk/Example/DigiMeFramework/CA_RSA_PRIVATE_KEY2.p12
```

- Open project in XCode, build and run on your iOS device;
- Press 'Start' button;
- Choose any contract from the list

![screen shot 1](https://raw.githubusercontent.com/digime/digime-ios-sdk/master/Example/ScreenShot1.png)

- If the digi.me app was installed and onborded then it will be opened by Example app;
- The contract view will appear. You can preview your data that will be shared using Consent Access;
- Press 'Authorise' to allow Consent Access to gather and forward your data

![screen shot 2](https://raw.githubusercontent.com/digime/digime-ios-sdk/master/Example/ScreenShot2.png)

- Example app will return to foreground;
- Shortly you should be able to preview your data in JSON file format

![screen shot 3](https://raw.githubusercontent.com/digime/digime-ios-sdk/master/Example/ScreenShot3.png)


##
Copyright © 2017 digi.me Ltd. All rights reserved.



