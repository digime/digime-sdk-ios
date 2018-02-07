//
//  NSError+SDK.m
//  CASDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "NSError+SDK.h"

@implementation NSError (SDK)

+ (NSError *)sdkError:(SDKError)sdkError
{
    return [NSError errorWithDomain:SDK_ERROR code:sdkError userInfo:@{ NSLocalizedDescriptionKey: [[self class] authDescription:sdkError]}];
}

+ (NSString *)authDescription:(SDKError)sdkError
{
    switch (sdkError) {
        case SDKErrorInvalidContract:
            return NSLocalizedString(@"Provided contractId has invalid format.", @"");
            break;
            
        case SDKErrorNoContract:
            return NSLocalizedString(@"No contracts registered! You must have forgotten to set contractId on DMEClient.", @"");
            break;
            
        case SDKErrorDecryptionFailed:
            return NSLocalizedString(@"Could not decrypt file content.", nil);
            
        case SDKErrorInvalidData:
            return NSLocalizedString(@"Could not serialize data.", nil);
            
        default:
            return @"";
            break;
    }
}

@end
