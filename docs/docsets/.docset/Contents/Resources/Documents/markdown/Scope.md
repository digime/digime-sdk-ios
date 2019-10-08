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

# Limiting Scope

Sometimes you may only want to retrieve a subset of data. This is governed at two levels. At the top are any scope limitations dictated by your contract; these can only be changed by digi.me support so please [contact support](https://developers.digi.me/contact-us) if you want to discuss this further.

At a code level, you can restrict the scope of a Private Sharing session by passing in a custom `DMEScope`.

## Defining `DMEScope`

`DMEScope` is comprised of two properties. `timeRanges` is a list of `DMETimeRange` objects (more on this below) to limit the breadth of time for which applicable data will be returned. `context` is set automatically and cannot be overridden.

### `DMETimeRange`:

`DMETimeRange` has 3 properties. `fromDate`, `toDate` and `last`. These are all optional but **at least one is required.**

We recommend you use one of the convenience methods provided:

```objc
//  A valid NSDate object representation of the earliest date you want data for. 
+ (DMETimeRange *)from:(NSDate *)from;

// A valid NSDate object representation of the date before which you would like data.
+ (DMETimeRange *)priorTo:(NSDate *)priorTo;

// A valid NSDate object representation of the start / end periods for which you want data for.
+ (DMETimeRange *)from:(NSDate *)from to:(NSDate *)to;

// An integer an a unit to describe date period you want the data for. Unit may be days, month or years
+ (DMETimeRange *)last:(NSUInteger)x unit:(DMETimeRangeUnit)unit;
```

## Providing `DMEScope`

When calling `authorize` on your `DMEPullClient`, simply pass in your `DMEScope` object:

```objc
DMEScope *scope = [DMEScope new];
scope.timeRanges = @[[DMETimeRange last:6 unit:DMETimeRangeUnitMonth]];
[pullClient authorizeWithScope:scope completion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        
}];
```

The data received from any subsequent calls to `getSessionData` will be limited by the scope of the session defined above.