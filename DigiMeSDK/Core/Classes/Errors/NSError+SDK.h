//
//  NSError+SDK.h
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const DME_SDK_ERROR = @"me.digi.sdk";

/**
Enum representing possible SDK errors.
*/
typedef NS_ENUM(NSInteger, SDKError) {
    SDKErrorNoContract = 1,         // No contract id set
    SDKErrorInvalidContract = 2,    // Contract id has invalid format
    SDKErrorDecryptionFailed = 3,   // Could not decrypt file content
    SDKErrorInvalidData = 4,        // Could not serialize data
    SDKErrorInvalidVersion = 5,     // This SDK version is no longer supported
    SDKErrorNoAppId = 6,            // No app id set
    SDKErrorNoPrivateKeyHex = 7,    // No private key hex set
    SDKErrorNoURLScheme = 8,        // URL Scheme not set in Info.plist
    SDKErrorDigiMeAppNotFound = 11, // Querying the 'digime' schema failed.
    SDKErrorFileListPollingTimeout = 12, // File List time out reached as there have been no changes.
    SDKErrorOAuthTokenNotSet = 13, // OAuth token not set on client instance.
    SDKErrorIncorrectContractType = 14, // Attempting to call ongoing API with a one-off contract.
};

/**
Convenience category used to generate an error in `DME_SDK_ERROR` domain
*/
@interface NSError (SDK)

+ (NSError *)sdkError:(SDKError)sdkError;
+ (void)setSDKError:(SDKError)sdkError toError:(NSError * _Nullable __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
