//
//  DMEClient.m
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEAPIClient.h"
#import "DMEAppCommunicator+Private.h"
#import "DMEClient+Private.h"
#import "DMEDataUnpacker.h"
#import "DMEGuestConsentManager.h"
#import "DMENativeConsentManager.h"
#import "DMEPreConsentViewController.h"
#import "DMESessionManager.h"
#import "DMEValidator.h"
#import "UIViewController+DMEExtension.h"
#import <DigiMeSDK/DigiMeSDK-Swift.h>

@implementation DMEClient

- (instancetype)initWithConfiguration:(id<DMEClientConfiguration>)configuration
{
    self = [super init];
    if (self)
    {
        _configuration = configuration;
        _apiClient = [[DMEAPIClient alloc] initWithConfiguration:configuration];
        _sessionManager = [[DMESessionManager alloc] initWithApiClient:_apiClient contractId:configuration.contractId];
        
        // Configure mercury appCommunicator.
        _appCommunicator = [DMEAppCommunicator shared];
    }
    
    return self;
}

- (nullable NSError *)validateClient
{
    if (!self.configuration.appId || [self.configuration.appId isEqualToString:@"YOUR_APP_ID"])
    {
        return [NSError sdkError:SDKErrorNoAppId];
    }
    
    NSArray *urlTypes = NSBundle.mainBundle.infoDictionary[@"CFBundleURLTypes"];
    NSArray *urlSchemes = [[urlTypes valueForKey:@"CFBundleURLSchemes"] valueForKeyPath: @"@unionOfArrays.self"];
    NSString *expectedUrlScheme = [NSString stringWithFormat:@"digime-ca-%@", self.configuration.appId];
    if (![urlSchemes containsObject:expectedUrlScheme])
    {
        return [NSError sdkError:SDKErrorNoURLScheme];
    }
    
    if (!self.configuration.contractId || [self.configuration.contractId isEqualToString:@"YOUR_CONTRACT_ID"])
    {
        return [NSError sdkError:SDKErrorNoContract];
    }
    
    if (![DMEValidator validateContractId:self.configuration.contractId])
    {
        return [NSError sdkError:SDKErrorInvalidContract];
    }
    
    return nil;
}

- (BOOL)viewReceiptInDMEAppWithError:(NSError * __autoreleasing * __nullable)error
{
    // Check we have both the appId and clientId, required for this.
    if (!self.configuration.contractId.length)
    {
        [NSError setSDKError:SDKErrorNoContract toError:error];
        return NO;
    }
    
    if (!self.configuration.appId.length)
    {
        [NSError setSDKError:SDKErrorNoAppId toError:error];
        return NO;
    }
    
    // Check the digime app can be opened (ie is installed).
    if (![self.appCommunicator canOpenDMEApp])
    {
        [NSError setSDKError:SDKErrorDigiMeAppNotFound toError:error];
        return NO;
    }
    
    // Prerequesits cleared, build URL.
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"digime";
    components.host = @"receipt";
    components.queryItems = @[[NSURLQueryItem queryItemWithName:@"contractid" value:self.configuration.contractId],
                              [NSURLQueryItem queryItemWithName:@"appid" value:self.configuration.appId]];
    
    NSURL *deeplinkingURL = components.URL;
    [[UIApplication sharedApplication] openURL:deeplinkingURL options:@{} completionHandler:nil];
    return YES;
}

@end

