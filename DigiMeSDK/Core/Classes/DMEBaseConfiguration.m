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

@property (nonatomic, strong, readwrite) NSString *baseUrl;

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
    }

    return self;
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
