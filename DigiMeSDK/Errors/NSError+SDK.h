//
//  NSError+SDK.h
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const SDK_ERROR = @"me.digi.sdk";

typedef NS_ENUM(NSInteger, SDKError) {
    SDKErrorNoContract = 1,
    SDKErrorInvalidContract = 2,
    SDKErrorDecryptionFailed = 3,
    SDKErrorInvalidData = 4
};

@interface NSError (SDK)

+ (NSError *)sdkError:(SDKError)sdkError;

@end
