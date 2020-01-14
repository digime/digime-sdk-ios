//
//  NSError+SDK.m
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "NSError+SDK.h"

@implementation NSError (SDK)

+ (NSError *)sdkError:(SDKError)sdkError
{
    return [NSError errorWithDomain:DME_SDK_ERROR code:sdkError userInfo:@{ NSLocalizedDescriptionKey: [[self class] sdkDescription:sdkError]}];
}

+ (void)setSDKError:(SDKError)sdkError toError:(NSError * _Nullable __autoreleasing *)error
{
    if (error != nil)
    {
        *error = [[self class] sdkError:sdkError];
    }
}

+ (NSString *)sdkDescription:(SDKError)sdkError
{
    switch (sdkError) {
        case SDKErrorInvalidContract:
            return @"Provided contractId has invalid format.";
            
        case SDKErrorNoContract:
            return @"No contracts registered! You must have forgotten to set contractId property on the configuration object.";
            
        case SDKErrorDecryptionFailed:
            return @"Could not decrypt file content.";
            
        case SDKErrorInvalidData:
            return @"Could not serialize data.";
            
        case SDKErrorInvalidVersion:
            return @"This SDK version is no longer supported.  Please update to a newer version.";
            
        case SDKErrorNoAppId:
            return @"No application registered! Please set appId property on the configuration object.";
            
        case SDKErrorNoPrivateKeyHex:
            return @"RSA private key hex not set. Please set the privateKeyHex property on the DMEPullConfiguration object.";
            
        case SDKErrorNoURLScheme:
            return @"Missing CFBundleURLScheme in Info.plist. Please refer to the README file to see how to set the callback URL Scheme";
            
        case SDKErrorDigiMeAppNotFound:
            return @"DigiMe app is not installed";
            
        case SDKErrorFileListPollingTimeout:
            return @"File List time out reached as there have been no changes during the number of retries specified in `DMEPullConfiguration`.";
            
        case SDKErrorOAuthTokenNotSet:
            return @"OAuth token not set on client instance. Please ensure that client instance is correctly initialized.";
            break;
    }
}

@end
