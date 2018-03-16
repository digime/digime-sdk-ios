//
//  CAAccounts.m
//  DigiMeSDK
//
//  Created on 05/02/2018.
//

#import "CAAccounts.h"
#import "NSError+SDK.h"

@implementation CAAccounts

#pragma mark - Deserialization

+ (CAAccounts *)deserialize:(NSData *)data error:(NSError * _Nullable __autoreleasing *)error
{
    id content = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:error];
    
    if ([content isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *json = (NSDictionary *)content;
        CAAccounts *accounts = [[self alloc] initWithFileId:@"accounts.json" json:json];
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
    NSMutableArray<CAAccount *> *accounts = [NSMutableArray new];
    
    for (NSDictionary *account in json)
    {
        NSDictionary *serviceJson = account[@"service"];
        NSString *serviceName = serviceJson[@"name"];
        
        CAServiceDescriptor *service;
        
        if (serviceName)
        {
            service = [[CAServiceDescriptor alloc] initWithName:serviceName logo:serviceJson[@"logo"]];
        }
        
        NSString *identifier = account[@"id"];
        NSString *name = account[@"name"];
        NSString *number = account[@"number"];
        
        CAAccount *mappedAccount = [[CAAccount alloc] initWithId:identifier name:name number:number service:service];
        [accounts addObject:mappedAccount];
    }
    
    _accounts = accounts;
}

@end

@implementation CAAccount

- (instancetype)initWithId:(NSString *)identifier name:(NSString *)name number:(NSString *)number service:(CAServiceDescriptor *)service
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

@implementation CAServiceDescriptor

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
