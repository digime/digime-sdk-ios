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

# Error Handling

Whilst using the SDK, you may encounter a number of errors. Some of these, we will attempt to recover from on your behalf, however, there are a large number that will require you to take some kind of action.

## Error Types

All invocations of the SDK that can return some form of error will return an instance of `NSError`. All errors come with a message explaining the reason behind them. There are 3 primary error domains - `me.digi.sdk`, `me.digi.sdk.api` and `me.digi.sdk.authorization`. Let's break them down:

### me.digi.sdk

These errors generally result from the misconfiguration of the SDK in some way, or other problems derived from the SDK's implementation within your app. The error messages are designed to be self-explainatory, so not all will be covered here. For some examples of the most common issues, and troubleshooting steps, see [Troubleshooting Common Issues](#troubleshooting-common-issues). This type of error will require address by the integrator of the SDK, due to being caused by an error on their part.

### me.digi.sdk.api

Just as `me.digi.sdk` domain represents issues on the integrator's side, `me.digi.sdk.api` reflects problems with the digi.me service. 

When the digi.me service returns an error, this will be passed back as `NSError` object with this domain. It's `localizedDescription` will contain the error message. Some of the error we handle internally within the SDK, retrying requests where appropriate, as per the retry rules you set in your `DMEClientConfiguration`. If, after exhausting this, we are unable to resolve the error, it will be passed onto you.

Where we are unable to deduce an error from our server's response we will pass one on as is - an HTTP 500 status would be one such use case.

Most server side errors are short lived, so the recommended course of action is to try again a bit later, but in the case of a persisting error, please contact digi.me support.

### me.digi.sdk.authorization

This should be the most common error encounter. In the event that a user declines to grant their consent, you will receive a `AuthErrorCancelled` code in `me.digi.sdk.authorization` domain; you may handle this in a way that's appropriate to your app.

## Retrying Requests

As touched on above, the SDK will retry any requests it deems potentially recoverable. The logic governing this can be influenced by properties on `DMEClientConfiguration`. Namely, the following:

```objc
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
```
You can also see the defaults assigned to each property above, should you need to explicitly override this.

## Troubleshooting Common Issues

Below are the 5 most common errors you could run into, and the steps you should take to rectify them:

#### `me.digi.sdk.authorization - AuthErrorInvalidSession`:

**Encountered**: If you try to fetch data after a session has expired.<br>
**Resolution**: Invoke `authorizeWithCompletion:` on a `DMEPullClient` again to obtain a new session. This may require the user to re-consent if you do not have an ongoing share agreement in place with them.


#### `me.digi.sdk - SDKErrorNoURLScheme`:

**Encountered**: If you do not set the right callback scheme in the `Info.plist`.<br>
**Resolution**: Ensure you add `CFBundleURLTypes` to your `Info.plist`, see [README](https://github.com/digime/digime-sdk-ios/blob/master/README.md) for details.

#### `me.digi.sdk - SDKErrorNoPrivateKeyHex`:
**Encountered**: When the SDK fails to parse the P12 file you specified with the password you specified.<br>
**Resolution**: Ensure that the P12 file exists in your project's `assets` folder, and that the name matches the one you specified. Ensure that the password is the one given to you by digi.me support, or, in sandbox, the one provided in the [README](https://github.com/digime/digime-sdk-ios/blob/master/README.md).

#### `me.digi.sdk - SDKErrorDigiMeAppNotFound`:
**Encountered**: When the user doesn't have the digi.me application installed, and you have disabled guest consent in the client config.
**Resolution**: Enable guest consent mode (see [Guest Consent](Guest-Consent.html) for more info), or, direct the user to install the digi.me app.

*Please Note: The SDK will automatically open the store listing for the digi.me app if this error is encountered and guest consent is disabled.*

## Further Issues

If, after reading this section, your issue persists, please contact digi.me developer support. The easiest way to do this is via our [Slack Workspace](https://developers.digi.me/slack/join). Here you can speak directly with other developers working with us, as well as digi.me's own development team.