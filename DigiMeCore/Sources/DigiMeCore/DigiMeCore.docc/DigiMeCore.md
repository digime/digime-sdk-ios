# DigiMeCore

DigiMeCore forms the backbone of the digi.me SDK, defining all the classes and fundamental structures used across the SDK. Serving as the foundational layer, it provides the essential components and definitions that are leveraged by the `DigiMeSDK` to facilitate its broad range of functionalities.

As a critical dependency module, `DigiMeCore` is automatically included when you integrate `DigiMeSDK` into your project. This seamless integration ensures that all core functionalities are readily available, providing a robust and stable base for the SDK's operations.

#### Importing DigiMeCore

While `DigiMeCore` is automatically included as part of the `DigiMeSDK`, you might find the need to directly access its object definitions and classes. In such cases, you can explicitly import `DigiMeCore` in your Swift classes to utilize its components. This is particularly useful for developers who require a deeper level of customization or wish to extend the functionality of the SDK.

To import `DigiMeCore` in your Swift files, simply use:

```swift
import DigiMeCore
```

This will grant you direct access to the underlying structures and classes defined in `DigiMeCore`, allowing you to leverage its capabilities to their fullest extent.

## DigiMeSDK
This is the primary SDK module. It encapsulates the core functionalities required to interact with the digi.me platform. It is designed for straightforward integration into your project.

[Go to DigiMeSDK Documentation](https://digime.github.io/digime-sdk-ios/DigiMeSDK/documentation/digimesdk/)

## DigiMeHealthKit
This module provides functionality specific to Apple HealthKit. It's an optional addition to the main SDK for apps that require access to Apple Health data.

[Go to DigiMeHealthKit Documentation](https://digime.github.io/digime-sdk-ios/DigiMeHealthKit/documentation/digimehealthkit/)
