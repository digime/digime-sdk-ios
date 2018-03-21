//
//  DMERequestFactory.m
//  DigiMeSDK
//
//  Created on 30/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "DMERequestFactory.h"

@interface DMERequestFactory()

@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong, readwrite) DMEClientConfiguration *config;

@end

@implementation DMERequestFactory

#pragma mark - Initialization

- (instancetype)initWithConfiguration:(DMEClientConfiguration *)configuration
{
    self = [super init];
    if (self)
    {
        _config = configuration;
    }
    
    return self;
}

#pragma mark - Public

- (NSURLRequest *)sessionRequestWithAppId:(NSString *)appId contractId:(NSString *)contractId
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@v1/permission-access/session", self.baseUrl]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.config.globalTimeout];
    
    NSDictionary *postKeys = @{@"appId" : appId, @"contractId" : contractId};
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postKeys options:0 error:nil];
    
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    return request;
}

- (NSURLRequest *)fileListRequestWithSessionKey:(NSString *)sessionKey
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@v1/permission-access/query/%@", self.baseUrl, sessionKey]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.config.globalTimeout];
    [request setHTTPMethod:@"GET"];
    return request;
}

- (NSURLRequest *)fileRequestWithId:(NSString *)fileId sessionKey:(NSString *)sessionKey
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@v1/permission-access/query/%@/%@", self.baseUrl, sessionKey, fileId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.config.globalTimeout];
    [request setHTTPMethod:@"GET"];
    return request;
}

- (NSString*)baseUrl
{
    if (!_baseUrl)
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"DMEConfig" ofType:@"plist"];
        NSDictionary *dict;
        
        if (filePath)
        {
            dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        }
        
        NSString *domain = dict[@"DME_DOMAIN"];
        if (!domain)
        {
            domain = @"digi.me";
        }
        _baseUrl = [NSString stringWithFormat:@"https://api.%@/", domain];
    }
    
    return _baseUrl;
}

@end
