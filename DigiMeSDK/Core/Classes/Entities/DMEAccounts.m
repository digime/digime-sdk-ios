//
//  DMEAccounts.m
//  DigiMeSDK
//
//  Created on 05/02/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEAccounts.h"
#import "NSError+SDK.h"
#import "DMECompressor.h"

@implementation DMEAccounts

#pragma mark - Deserialization

+ (DMEAccounts *)deserialize:(NSData *)data error:(NSError * _Nullable __autoreleasing *)error
{
    id content = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:error];
    
    if ([content isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *json = (NSDictionary *)content;
        DMEAccounts *accounts = [[self alloc] initWithFileId:@"accounts.json" json:json];
        return accounts;
    }
    
    if (error != nil)
    {
        *error = [NSError sdkError:SDKErrorInvalidData];
    }
    
    return nil;
}

#pragma mark - Initialization

- (instancetype)initWithFileId:(NSString *)fileId json:(nonnull NSDictionary *)json
{
    self = [super init];
    if (self)
    {
        _fileId = fileId;
        _json = json;
        
        NSArray *accounts = json[@"accounts"];
        [self populateWithJSON:accounts];
    }
    
    return self;
}

- (void)populateWithJSON:(NSArray *)json
{
    NSMutableArray<DMEAccount *> *accounts = [NSMutableArray new];
    
    for (NSDictionary *account in json)
    {
        NSDictionary *serviceJson = account[@"service"];
        NSString *serviceName = serviceJson[@"name"];
        
        DMEServiceDescriptor *service;
        
        if (serviceName)
        {
            service = [[DMEServiceDescriptor alloc] initWithName:serviceName logo:serviceJson[@"logo"]];
        }
        
        NSString *identifier = account[@"id"];
        NSString *name = account[@"name"];
        NSString *number = account[@"number"];
        
        DMEAccount *mappedAccount = [[DMEAccount alloc] initWithId:identifier name:name number:number service:service];
        [accounts addObject:mappedAccount];
    }
    
    _accounts = accounts;
}

@end

@implementation DMEAccount

- (instancetype)initWithId:(NSString *)identifier name:(NSString *)name number:(NSString *)number service:(DMEServiceDescriptor *)service
{
    self = [super init];
    if (self)
    {
        _identifier = identifier;
        _name = name;
        _number = number;
        _service = service;
    }
    
    return self;
}

@end

@implementation DMEServiceDescriptor

- (instancetype)initWithName:(NSString *)name logo:(NSString *)logo
{
    self = [super init];
    if (self)
    {
        _name = name;
        _logo = logo;
    }
    
    return self;
}

@end
