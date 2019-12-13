//
//  DMEPullConfiguration.m
//  DigiMeSDK
//
//  Created on 08/08/2019
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMECryptoUtilities.h"
#import "DMEPullConfiguration.h"

@implementation DMEPullConfiguration

- (instancetype)initWithAppId:(NSString *)appId contractId:(NSString *)contractId privateKeyHex:(NSString *)privateKeyHex
{
    self = [super initWithAppId:appId contractId:contractId];
    if (self)
    {
        _privateKeyHex = privateKeyHex;
        _guestEnabled = YES;
        _pollInterval = 3.0;
        _maxStalePolls = 100;
    }
    
    return self;
}

- (nullable instancetype)initWithAppId:(NSString *)appId contractId:(NSString *)contractId p12FileName:(NSString *)p12FileName p12Password:(NSString *)p12Password
{
    NSString *privateKeyHex = [DMECryptoUtilities privateKeyHexFromP12File: p12FileName password: p12Password];
    
    if (!privateKeyHex)
    {
        return nil;
    }
    
    return [self initWithAppId:appId contractId:contractId privateKeyHex:privateKeyHex];
}

- (instancetype)initForOngoingAccessWithAppId:(NSString *)appId contractId:(NSString *)contractId publicKeyHex:(nullable NSString *)publicKeyHex privateKeyHex:(NSString *)privateKeyHex
{
    self = [self initWithAppId:appId contractId:contractId privateKeyHex:privateKeyHex];
    if (self)
    {
        _publicKeyHex = publicKeyHex;
        _privateKeyHex = privateKeyHex;
        _guestEnabled = NO;
    }
    
    return self;
}

@end
