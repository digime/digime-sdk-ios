//
//  DMERequestFactory.m
//  DigiMeSDK
//
//  Created on 30/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEClientConfiguration.h"
#import "DMERequestFactory.h"
#import "DMEDataRequestSerializer.h"
#import "NSData+DMECrypto.h"
#import <DigiMeSDK/DigiMeSDK-Swift.h>

static NSString * const kDigiMeAPIVersion = @"v1.4";
static NSString * const kDigiMeOAuthAPIVersion = @"v1.4";
static NSString * const kDigiMeJWKSAPIVersion = @"v1.4";

@interface DMERequestFactory()

@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong, readwrite) id<DMEClientConfiguration> config;
@property (nonatomic, strong) NSDictionary *sdkAgent;

@end

@implementation DMERequestFactory

#pragma mark - Initialization

- (instancetype)initWithConfiguration:(id<DMEClientConfiguration>)configuration
{
    self = [super init];
    if (self)
    {
        _config = configuration;
    }
    
    return self;
}

#pragma mark - Public

- (NSURLRequest *)preAuthRequestWithBearer:(NSString *)jwtBearer
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/authorize", self.baseOAuthUrlPath]];
    NSString *authorization = [NSString stringWithFormat:@"Bearer %@", jwtBearer];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.config.globalTimeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    return request;
}

- (NSURLRequest *)preAuthValidationRequest
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth", self.baseJWKSUrlPath]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.config.globalTimeout];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    return request;
}

- (NSURLRequest *)authRequestWithBearer:(NSString *)jwtBearer
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/token", self.baseOAuthUrlPath]];
    NSString *authorization = [NSString stringWithFormat:@"Bearer %@", jwtBearer];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.config.globalTimeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    return request;
}

- (NSURLRequest *)dataTriggerRequestWithBearer:(NSString *)jwtBearer
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/trigger?schemaVersion=5.0.0&prefetch=false", self.baseUrlPath]];
    NSString *authorization = [NSString stringWithFormat:@"Bearer %@", jwtBearer];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.config.globalTimeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    return request;
}

- (NSURLRequest *)sessionRequestWithAppId:(NSString *)appId contractId:(NSString *)contractId options:(DMESessionOptions *)options
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/session", self.baseUrlPath]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.config.globalTimeout];
    
    NSMutableDictionary *postKeys = [NSMutableDictionary new];
    postKeys[@"appId"] = appId;
    postKeys[@"contractId"] = contractId;
    postKeys[@"sdkAgent"] = self.sdkAgent;
    postKeys[@"accept"] = @{ @"compression" : @"gzip" };
    
    if (options.scope != nil)
    {
        NSDictionary *serializedScope = [DMEDataRequestSerializer serialize:options.scope];
        
        if (serializedScope != nil)
        {
            postKeys[options.scope.context] = serializedScope;
        }
    }
    
    if (options.limits != nil)
    {
        NSInteger duration = options.limits.duration.sourceFetch;
        postKeys[@"limits"] =
        @{
            @"duration": @{
                    @"sourceFetch": @(duration)
            }
        };
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

- (NSURLRequest *)pushRequestWithPostboxId:(NSString *)postboxId payload:(NSData *)data headerParameters:(NSDictionary *)headers
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/postbox/%@", self.baseUrlPath, postboxId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.config.globalTimeout];
    
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = [self generateBoundaryString];
    NSString *metadata = [[headers[@"metadata"] stringByReplacingOccurrencesOfString:@"\n" withString:@""]stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSString *symmetricalKey = [[headers[@"symmetricalKey"] stringByReplacingOccurrencesOfString:@"\n" withString:@""]stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:headers[@"sessionKey"] forHTTPHeaderField: @"sessionKey"];
    [request setValue:symmetricalKey forHTTPHeaderField: @"symmetricalKey"];
    [request setValue:headers[@"iv"] forHTTPHeaderField: @"iv"];
    [request setValue:metadata forHTTPHeaderField: @"metadata"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: multipart/form-data\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n\r\n", @"file", @"file"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (data)
    {
        [body appendData:data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    return request;

}

- (NSString *)generateBoundaryString {
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}

- (NSString *)baseUrl
{
    return self.config.baseUrl;
}

- (NSString *)baseUrlPath
{
    return [NSString stringWithFormat:@"%@%@/permission-access", self.baseUrl, kDigiMeAPIVersion];
}

- (NSString *)baseOAuthUrlPath
{
    return [NSString stringWithFormat:@"%@%@/oauth", self.baseUrl, kDigiMeOAuthAPIVersion];
}

- (NSString *)baseJWKSUrlPath
{
    return [NSString stringWithFormat:@"%@%@/jwks", self.baseUrl, kDigiMeJWKSAPIVersion];
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
