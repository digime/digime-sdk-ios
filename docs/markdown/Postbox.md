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

# Postbox

## Introduction

digi.me is a data portability facilitator. As such, we support the flow of data in both directions - from the user to you, and from you back to the user. This process of 'giving data back' is known as Postbox and will henceforth be referred to as such.

Instances may arise where you wish to utilise data not currently supported by digi.me natively, Postbox allows you to do this. It does what it says on the tin, acts as a postbox for data into a user's digi.me.

## Types of Push

When pushing data to Postbox you have two main options:

#### Data pre-mapped into digi.me's ontology:

digi.me publishes it's data ontology [here](https://developers.digi.me/reference-api) for the various data types. When making a submission, if you push data normalised to this format, it will be displayed in the digi.me more appropriately, with UI specifically engineered to maximise the value of that data. It also means that when you or another third party requests this data via pull, it can be included within a collection of data points of the same type.

#### Unmapped data ([Raw Data]()):

digi.me can also act as a vault for data that does not fit within our current ontology, whether to collate user data together in one place or to act as a conduit between a data provider and data consumer.