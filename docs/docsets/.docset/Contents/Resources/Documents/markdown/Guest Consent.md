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

# Guest Consent

Whilst the true power of the digi.me Private Sharing platform lies in the user's digi.me, and as such highly encourage developers to properly utilise this, we do facilitate your app accessing the data of users, without the digi.me app, however we leave that choice up to the user. This feature is known as *Guest Consent* or *One Time Private Sharing*. It is effecively the digi.me onboarding process, within a web browser.

## How to Use

Guest Consent is enabled by default.

If the digi.me app is not installed, the default behaviour is to present the user with a choice:

- Open the relevant app store listing for the user to subsequently download and set up digi.me.
- Use guest onboarding, which if selected the user will be taken through the web onboarding

You may disable *Guest Consent* by setting the `guestEnabled` property in `DMEPullConfiguration` object to `NO`.

> Note that even if Guest Consent is enabled, if the digi.me app is present on the device, we will always process the consent request through the native app.


## Considerations

Guest Consent removes the need for your user to have the digi.me app on their device. Whilst this might sound like a positive, there are a number of drawbacks to Guest Consent.

#### Drawbacks:

- Any data the user imports is lost after your SDK session expires. Data is temporarily cached in memory (RAM is volatile, which is important as we don't see, touch or hold user data), as such, this is lost once the corresponding session container is invalidated.
- Ongoing shares are not available through Guest Consent, due to aforementioned loss of data once a session has lapsed.
- Whilst data is transferred over HTTPS with full TLS 1.2, we are unable to verify the server's certificate client side and as such, we can't guarentee the integrity of the data served. The digi.me client is fully certificate pinned and has a strict trust policy enforced.