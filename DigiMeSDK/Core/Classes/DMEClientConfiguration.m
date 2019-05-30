//
//  DMEClientConfiguration.m
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEClientConfiguration.h"

NSString * const kDMEClientSchemePrefix = @"digime-ca-";
NSString * const kDMEConfigFileName = @"DMEConfig";

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
