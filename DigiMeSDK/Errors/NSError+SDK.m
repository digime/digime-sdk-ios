//
//  NSError+SDK.m
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "NSError+SDK.h"

@implementation NSError (SDK)

+ (NSError *)sdkError:(SDKError)sdkError
{
    return [NSError errorWithDomain:SDK_ERROR code:sdkError userInfo:@{ NSLocalizedDescriptionKey: [[self class] sdkDescription:sdkError]}];
}

+ (NSString *)sdkDescription:(SDKError)sdkError
{
    switch (sdkError) {
        case SDKErrorInvalidContract:
            return @"Provided contractId has invalid format.";
            break;
            
        case SDKErrorNoContract:
            return @"No contracts registered! You must have forgotten to set contractId on DMEClient.";
            break;
            
        case SDKErrorDecryptionFailed:
            return @"Could not decrypt file content.";
            
        case SDKErrorInvalidData:
            return @"Could not serialize data.";
    }
}

@end
