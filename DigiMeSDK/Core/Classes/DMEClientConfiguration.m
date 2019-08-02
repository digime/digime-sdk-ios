//
//  DMEClientConfiguration.m
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEClientConfiguration.h"
#import "DMECryptoUtilities.h"

NSString * const kDMEClientSchemePrefix = @"digime-ca-";
NSString * const kDMEConfigFileName = @"DMEConfig";

@interface DMEClientConfiguration()

@property (nonatomic, strong, readwrite) NSString *baseUrl;

@end

@implementation DMEClientConfiguration

#pragma mark - Initialization
- (instancetype)init
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

- (instancetype)initWithAppId:(NSString *)appId contractId:(NSString *)contractId privateKeyHex:(NSString *)privateKeyHex
{
    self = [self init];
    if (self)
    {
        _appId = appId;
        _contractId = contractId;
        _privateKeyHex = privateKeyHex;
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

- (NSString *)baseUrl
{
    if (!_baseUrl)
    {
        NSDictionary *dict;
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [[documentsPath stringByAppendingPathComponent:kDMEConfigFileName] stringByAppendingPathExtension:@"plist"];
        
        if (filePath)
        {
            dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        }
        
        if (!dict)
        {
            filePath = [[NSBundle mainBundle] pathForResource:kDMEConfigFileName ofType:@"plist"];
            
            if (filePath)
            {
                dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
            }
        }

        NSString *domain = dict[@"DME_DOMAIN"] ?: @"digi.me";
        _baseUrl = [NSString stringWithFormat:@"https://api.%@/", domain];
    }
    
    return _baseUrl;
}

@end
