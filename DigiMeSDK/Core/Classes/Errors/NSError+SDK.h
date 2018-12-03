//
//  NSError+SDK.h
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const SDK_ERROR = @"me.digi.sdk";

typedef NS_ENUM(NSInteger, SDKError) {
    SDKErrorNoContract = 1,         // No contract id set
    SDKErrorInvalidContract = 2,    // Contract id has invalid format
    SDKErrorDecryptionFailed = 3,   // Could not decrypt file content
    SDKErrorInvalidData = 4,        // Could not serialize data
    SDKErrorInvalidVersion = 5,     // This SDK version is no longer supported
    SDKErrorNoAppId = 6,            // No app id set
    SDKErrorNoPrivateKeyHex = 7,    // No private key hex set
    SDKErrorNoURLScheme = 8,        // URL Scheme not set in Info.plist
    SDKErrorSerializationError = 9, // Failed to serialize data
    SDKErrorEncryptedDataCallback = 10,  // Attempting to retrieve encrypted data with client callback (which is not allowed)
};

@interface NSError (SDK)

+ (NSError *)sdkError:(SDKError)sdkError;

@end

NS_ASSUME_NONNULL_END
