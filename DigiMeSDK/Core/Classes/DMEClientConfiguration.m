//
//  DMEClientConfiguration.m
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEClientConfiguration.h"

NSString * const kDMEClientSchemePrefix = @"digime-ca-";

@interface DMEClientConfiguration()

@property (nonatomic, strong, readwrite) NSString *baseUrl;

@end

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

- (NSString *)baseUrl
{
    if (!_baseUrl)
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"DMEConfig" ofType:@"plist"];
        NSDictionary *dict;
        
        if (filePath)
        {
            dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        }
        
        NSString *domain = dict[@"DME_DOMAIN"] ?: @"digi.me";
        _baseUrl = [NSString stringWithFormat:@"https://api.%@/", domain];
    }
    
    return _baseUrl;
}

@end
