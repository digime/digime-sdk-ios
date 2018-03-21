//
//  DMEClientConfiguration.m
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "DMEClientConfiguration.h"

@implementation DMEClientConfiguration

#pragma mark - Initialization

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _globalTimeout = 25;
        _retryOnFail = YES;
        _retryDelay = 750;
        _retryWithExponentialBackOff = YES;
        _maxRetryCount = 5;
        _maxConcurrentRequests = 5;
        _debugLogEnabled = NO;
    }
    
    return self;
}

@end
