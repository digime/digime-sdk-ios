//
//  DMEClientConfiguration.m
//  DigiMeSDK
//
//  Created on 08/08/2019
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEBaseConfiguration.h"

NSString * const kDMEConfigFileName = @"DMEConfig";

@interface DMEBaseConfiguration()

@end

@implementation DMEBaseConfiguration

#pragma mark - Initialization

- (instancetype)initWithAppId:(NSString *)appId contractId:(NSString *)contractId
{
    self = [super init];
    if (self)
    {
        _appId = appId;
        _contractId = contractId;
        _globalTimeout = 25;
        _retryOnFail = YES;
        _retryDelay = 750;
        _retryWithExponentialBackOff = YES;
        _maxRetryCount = 5;
        _maxConcurrentRequests = 5;
        _debugLogEnabled = NO;
        _baseUrl = @"https://api.digi.me/";
    }

    return self;
}

@end
