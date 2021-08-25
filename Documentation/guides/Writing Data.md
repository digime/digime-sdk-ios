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

# Writing Data

<hr>
**This SDK feature is for evaluation purposes only.**

Please get in touch if you are interested in using it in a live product solution by emailing [support@digi.me](mailto:support@digi.me) and we can discuss your requirements and the suitability of writing data within your solution.
<hr>

## Introduction

digi.me is a data portability facilitator. As such, we support the flow of data in both directions - from the user to you, and from you back to the user.

Instances may arise where you wish to utilise data not currently supported by digi.me natively, writing data allows you to do this. It does what it says on the tin, acts as a gateway to push data into a user's digi.me.

## Types of Push

When pushing data to digi.me you have two main options:

#### Data pre-mapped into digi.me's ontology:

digi.me publishes it's data ontology [here](https://developers.digi.me/reference-api) for the various data types. When making a submission, if you push data normalised to this format, it will be displayed in the digi.me more appropriately, with UI specifically engineered to maximise the value of that data. It also means that when you or another third party requests this data via pull, it can be included within a collection of data points of the same type.

#### Unmapped data ([Raw Data](raw-data.html)):

digi.me can also act as a vault for data that does not fit within our current ontology, whether to collate user data together in one place or to act as a conduit between a data provider and data consumer. When data that doesn't correspond to one of digi.me's object types is pushed, this will be rendered within digi.me as a raw 'data drop'. If we can deserialise this to JSON, we will show the raw JSON tree, otherwise there will be no facility to preview the data - this is for security reasons.

## Pushing Data

The digi.me Private Sharing SDK makes it easy to create a postbox to push data to. Similarly to requesting data, you can achieve this by utilising a client object as follows:

To push data, you need to build a JSON `metadata` object that describes what data your pushing along with the NSData representation of your data itself. An example showing Postbox creation and push can be seen below.:

```swift
let data: Data = ... // Obtain the data you wish to post.
let metadata: Data = ... // All push submissions must be pushed with appropriate metadata. See the example apps for more details.

digiMe.write(data: data, metadata: metadata) { error in
  // Handle error, if any.
}
```

*NB: Please refer to our Write example in the [Swift Example App](https://github.com/digime/digime-sdk-ios/tree/master/ExampleSwift) for more details on data and metadata.*
