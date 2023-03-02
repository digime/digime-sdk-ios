# Error Handling

Whilst using the SDK, you may encounter a number of errors. Some of these, we will attempt to recover from on your behalf, however, there are a large number that will require you to take some kind of action.

## Error Types

All invocations of the SDK that can return some form of error will return an instance of `SDKError`.

Some errors represent incorrect SDK setup while most represent server or runtime errors. These are described below with steps to rectify some of the common errors.

### SDK Setup Errors

These errors generally result from the misconfiguration of the SDK in some way, or other problems derived from the SDK's implementation within your app. The error messages are designed to be self-explainatory, so not all will be covered here. This type of error will require address by the integrator of the SDK, due to being caused by an error on their part.

---
##### `SDKError.noUrlScheme`:

**Encountered**: If you do not set the right callback scheme in the `Info.plist`.<br>
**Resolution**: Ensure you add `CFBundleURLTypes` to your `Info.plist`, see [README](https://github.com/digime/digime-sdk-ios/blob/master/README.md) for details.

---

##### `SDKError.invalidPrivateOrPublicKey`:
**Encountered**: When the private or public key given to `configuration` initializer is not of the correct format.<br>
**Resolution**: Ensure that the keys you specify are the full RSA private or public key including header and footer. i.e.<br>

```swift
-----BEGIN RSA PRIVATE KEY----
{KEY CONTENT}
-----END RSA PRIVATE KEY-----
```

---

### Server Errors

When the digi.me service returns an error, this will generally be passed back as `SDKError.httpResponseError` or as `SDKError.urlRequestFailed`, both containing the underlying error message. Some of the errors we handle internally within the SDK, retrying requests where appropriate. If, after exhausting this, we are unable to resolve the error, it will be passed onto you.

Some of the server errors are common enough that they have been mapped to specific SDKErrors, for example `SDKError.scopeOutOfBounds` and `SDKError.incorrectContractType`. These should only be encountered during SDK integration as they require programming changes to fix.

Most server side errors are short lived, so the recommended course of action is to try again a bit later, but in the case of a persisting error, please contact digi.me support.

### Other Runtime Errors

The remaining runtime errors generally fall into one of 2 camps - recoverable and unrecoverable

#### Recoverable Errors

The following are some of the most common recoverable errors:

---

##### `SDKError.invalidSession`:

**Encountered**: If you try to read data after a session has expired.<br>
**Resolution**: Either explicitly call `DigiMe.requestDataQuery` to obtain a new session or call `DigiMe.readAllFiles` which implicitly obtains a new session.

---

##### `SDKError.authorizationCancelled`: 

**Encountered**: When user declines to grant their consent.<br>
**Resolution**: You may handle this in a way that's appropriate to your app.

---

##### `SDKError.alreadyReadingAllFiles`:

**Encountered**: If multiple simultaneous calls to `DigiMe.readAllFiles` are made. Only one call to this method is allowed at any time as it may trigger the server to refresh data from external sources.<br>
**Resolution**: If you need to make multiple calls, you should ensure that these calls are performed serially.

---

##### `SDKError.fileListPollingTimeout`:

**Encountered**: This typically appears in the completion block of `DigiMe.readAllFiles` and indicates that the SDK has made multiple calls to retrieve file list with there being no changes to contents of file list. This is usually due to the server running a synchronization between service and user's digi.me which is taking too long (denoted by `FileList.status.state` not completing in a timely manner).<br>
**Resolution**: Make a subsequent call to `DigiMe.readAllFiles` at a later date to see if the synchronization finishes.

---

#### Unrecoverable Errors

There are some errors which should never be encountered, which indicate a failure of the SDK. If encountered, please contact digi.me support.
In particular, these are `SDKError.writeRequestFailure`, `SDKError.invalidData`, and `SDKError.invalidWriteMetadata`.


## Further Issues

If, after reading this section, your issue persists, please contact digi.me developer support. The easiest way to do this is via our [Slack Workspace](https://developers.digi.me/slack/join). Here you can speak directly with other developers working with us, as well as digi.me's own development team.
