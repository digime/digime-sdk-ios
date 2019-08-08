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

@end
