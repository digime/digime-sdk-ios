//
//  DMERequestFactory.m
//  DigiMeSDK
//
//  Created on 30/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMERequestFactory.h"
#import "CADataRequestSerializer.h"

static NSString * const kDigiMeAPIVersion = @"v1";

@interface DMERequestFactory()

@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong, readwrite) DMEClientConfiguration *config;
@property (nonatomic, strong) NSDictionary *sdkAgent;

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

- (NSURLRequest *)sessionRequestWithAppId:(NSString *)appId contractId:(NSString *)contractId scope:(nullable id<CADataRequest>)scope
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/session", self.baseUrlPath]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.config.globalTimeout];
    
    NSMutableDictionary *postKeys = [NSMutableDictionary new];
    postKeys[@"appId"] = appId;
    postKeys[@"contractId"] = contractId;
    postKeys[@"sdkAgent"] = self.sdkAgent;
    postKeys[@"accept"] = @{ @"compression" : @"brotli" };
    
    if (scope != nil)
    {
        NSDictionary *serializedScope = [CADataRequestSerializer serialize:scope];
        
        if (serializedScope != nil)
        {
            postKeys[scope.context] = serializedScope;
        }
    }
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postKeys options:0 error:nil];
    
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    return request;
}

- (NSURLRequest *)fileListRequestWithSessionKey:(NSString *)sessionKey
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/query/%@", self.baseUrlPath, sessionKey]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.config.globalTimeout];
    [request setHTTPMethod:@"GET"];
    return request;
}

- (NSURLRequest *)fileRequestWithId:(NSString *)fileId sessionKey:(NSString *)sessionKey
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/query/%@/%@", self.baseUrlPath, sessionKey, fileId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.config.globalTimeout];
    [request setHTTPMethod:@"GET"];
    return request;
}

- (NSString *)baseUrl
{
    return self.config.baseUrl;
}

- (NSString *)baseUrlPath
{
    return [NSString stringWithFormat:@"%@%@/permission-access", self.baseUrl, kDigiMeAPIVersion];
}

- (NSDictionary *)sdkAgent
{
    if (_sdkAgent == nil)
    {
        NSString *sdkVersion = [[NSBundle bundleForClass:self.class] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
        NSString *sdkName = @"ios";
        _sdkAgent = @{
                      @"name": sdkName,
                      @"version": sdkVersion,
                      };
    }
    
    return _sdkAgent;
}

@end
