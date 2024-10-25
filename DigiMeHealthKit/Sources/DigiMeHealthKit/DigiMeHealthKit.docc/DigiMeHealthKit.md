# DigiMeHealthKit Module

The `DigiMeHealthKit` module is a specialized extension of the Digi.me SDK tailored for applications that require access to health-related data via Apple's HealthKit.

## Overview

`DigiMeHealthKit` seamlessly integrates with the Digi.me SDK to provide access to health and fitness data from the user's device. This module is optional and should only be included in projects where HealthKit data is needed.

## Features

- **Fitness Activity Data**: Import fitness activity data such as Steps, Active Energy, Exercise Minutes, and Walking & Running Distance.
- **User Privacy**: Ensures user data privacy by following the consent-driven data access flow provided by the digi.me platform.

## Installation

### Swift Package Manager (SPM)

```swift
.package(name: "DigiMeHealthKit", url: "https://github.com/digime/digime-healthkit-ios.git", from: "x.x.x")
```

### CocoaPods

Add `DigiMeHealthKit` to your `Podfile`:

```ruby
pod 'DigiMeHealthKit'
```

Then run:

```bash
pod install --repo-update
```

## Usage

To use the `DigiMeHealthKit` module, ensure you have the proper permissions set in your app's `Info.plist` file to access HealthKit data.

Import `DigiMeHealthKit` in your Swift files where you want to access HealthKit data:

```swift
import DigiMeHealthKit
```

## Documentation

For more detailed documentation on how to use `DigiMeHealthKit`, please refer to the DigiMeHealthKit Documentation bellow.

## DigiMeSDK
This is the primary SDK module. It encapsulates the core functionalities required to interact with the digi.me platform. It is designed for straightforward integration into your project.

[Go to DigiMeSDK Documentation](https://digime.github.io/digime-sdk-ios/DigiMeSDK/documentation/digimesdk/)

## DigiMeCore
DigiMeCore defines all the classes and fundamental definitions used across the SDK. It serves as the foundational layer upon which DigiMeSDK builds. As a critical dependency module, `DigiMeCore` is automatically included when you integrate `DigiMeSDK` into your project. 

While `DigiMeCore` is automatically included as part of the `DigiMeSDK`, you might find the need to directly access its object definitions and classes. In such cases, you can explicitly import `DigiMeCore` in your Swift classes to utilize its components. 

[Go to DigiMeCore Documentation](https://digime.github.io/digime-sdk-ios/DigiMeCore/documentation/digimecore/)

## Example

Check out our [DigiMeSDKExample app](https://github.com/digime/digime-sdk-ios) that demonstrates how to integrate and use `DigiMeHealthKit` in conjunction with the Digi.me SDK.

## Support

For support, questions, or more information, please visit [developers.digi.me](https://developers.digi.me/) or contact us at [support@digi.me](mailto:support@digi.me).
