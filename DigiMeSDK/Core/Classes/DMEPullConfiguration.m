//
//  DMEPullConfiguration.m
//  DigiMeSDK
//
//  Created on 08/08/2019
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEPullConfiguration.h"

@implementation DMEPullConfiguration

- (instancetype)initWithAppId:(NSString *)appId contractId:(NSString *)contractId privateKeyHex:(NSString *)privateKeyHex
{
    self = [super initWithAppId:appId contractId:contractId privateKeyHex:privateKeyHex];
    if (self)
    {
        _guestEnabled = YES;
        _pollInterval = 3.0;
        _maxStalePolls = 100;
    }
    
    return self;
}

@end
