//
//  DMERequestFactory.m
//  DigiMeSDK
//
//  Created on 30/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "DMERequestFactory.h"
#import "CADataRequestSerializer.h"

static NSString * const kDigiMeAPIVersion = @"v1";

@interface DMERequestFactory()

@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong, readwrite) DMEClientConfiguration *config;
@property (nonatomic, strong) NSString *userAgentString;

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
    postKeys[@"sdkAgent"] = self.userAgentString;
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

- (NSString *)baseUrlPath
{
    return [NSString stringWithFormat:@"%@%@/permission-access", self.baseUrl, kDigiMeAPIVersion];
}

- (NSString *)userAgentString
{
    if (_userAgentString == nil)
    {
        NSString *sdkVersion = [[NSBundle bundleForClass:self.class] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
        UIDevice *device = UIDevice.currentDevice;
        NSString *deviceModel = device.model;
        NSString *osVersion = device.systemVersion;
        _userAgentString = [NSString stringWithFormat:@"digi.me.sdk/%@ (%@; ios; %@)", sdkVersion, deviceModel, osVersion];
    }
    
    return _userAgentString;
}

@end
