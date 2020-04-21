//
//  DMEFiles.m
//  DigiMeSDK
//
//  Created on 13/08/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEFileList.h"
#import <DigiMeSDK/DigiMeSDK-Swift.h>

@interface DMEFileList ()

@property (nonatomic, strong, readwrite) NSArray<DMEFileListItem *> *files;
@property (nonatomic, readwrite) DMEFileSyncState syncState;

@end

@implementation DMEFileList

#pragma mark - Initialization

- (instancetype)initWithJSON:(NSDictionary *)json
{
    self = [super init];
    
    if (self)
    {
        NSMutableArray *files = [NSMutableArray new];
        
        NSArray *fileListArray = json[@"fileList"];
        if (fileListArray && [fileListArray isKindOfClass:[NSArray class]])
        {
            [fileListArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![obj isKindOfClass:[NSDictionary class]])
                {
                    return;
                }
                
                NSDictionary *dict = (NSDictionary *)obj;
                NSString *name = dict[@"name"];
                NSTimeInterval interval = [dict[@"updatedDate"] integerValue] / 1000;
                NSDate *updatedDate = [NSDate dateWithTimeIntervalSince1970: interval];
                DMEFileListItem *item = [[DMEFileListItem alloc] initWithName:name updateDate:updatedDate];
                [files addObject:item];
            }];
        }
        
        _files = files;
        _syncStateString = json[@"status"][@"state"];
        _syncState = [[self class] syncStateFromString:_syncStateString];
        
        id accountsJson = json[@"status"][@"details"];
        
        if ([accountsJson isKindOfClass:[NSDictionary class]])
        {
            _accounts = [self accountsFromJson:(NSDictionary *)accountsJson];
        }
        else
        {
            _accounts = @[];
        }
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
      return YES;
    }
    
    if (![object isKindOfClass:[DMEFileList class]])
    {
        return NO;
    }
    
    DMEFileList *other = (DMEFileList *)object;
    return [self.files isEqualToArray:other.files] && self.syncState == other.syncState && [self.accounts isEqualToArray:other.accounts];
}

- (NSUInteger)hash
{
    return self.files.hash ^ self.syncState ^ self.accounts.hash;
}

- (NSArray<DMEFileListAccount *> *)accountsFromJson:(NSDictionary *)json
{
    NSMutableArray <DMEFileListAccount *> *accounts = [NSMutableArray new];
    
    // dictionary where each key represents an account identifier, and value is a dictionary with details
    /**
     "<accountid>": {...},
     "<accountid>": {...},
     */
    
    NSArray *accountKeys = [json allKeys];
    
    [accountKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSString class]])
        {
            return;
        }
        
        NSString *accountId = (NSString *)obj;
        NSDictionary *accountJson = json[accountId];
        NSDictionary *error = accountJson[@"error"];
        id syncString = accountJson[@"state"];
        DMEFileSyncState syncState = DMEFileSyncStateUnknown;
        
        if ([syncString isKindOfClass:[NSString class]])
        {
            syncState = [[self class] syncStateFromString:(NSString *)syncString];
        }
        
        DMEFileListAccount *fileListAccount = [[DMEFileListAccount alloc] initWithIdentifier:accountId syncState:syncState error:error];
        [accounts addObject:fileListAccount];
    }];
    
    return accounts;
}

- (NSArray<NSString *> *)fileIds
{
    return [self.files valueForKey:@"name"];
}

+ (NSString *)syncStateStringFromState:(DMEFileSyncState)state
{
    switch (state) {
        case DMEFileSyncStateUnknown:
            return @"unknown";
            
        case DMEFileSyncStatePartial:
            return @"partial";
            
        case DMEFileSyncStatePending:
            return @"pending";
            
        case DMEFileSyncStateRunning:
            return @"running";
            
        case DMEFileSyncStateCompleted:
            return @"completed";
    }
}

+ (DMEFileSyncState)syncStateFromString:(nullable NSString *)string
{
    if ([string isEqualToString:@"running"])
    {
        return DMEFileSyncStateRunning;
    }
    else if ([string isEqualToString:@"pending"])
    {
        return DMEFileSyncStatePending;
    }
    else if ([string isEqualToString:@"partial"])
    {
        return DMEFileSyncStatePartial;
    }
    else if ([string isEqualToString:@"completed"])
    {
        return DMEFileSyncStateCompleted;
    }
    else
    {
        return DMEFileSyncStateUnknown;
    }
}

@end

@implementation DMEFileListAccount

- (instancetype)initWithIdentifier:(NSString *)identifier syncState:(DMEFileSyncState)syncState error:(NSDictionary *)error
{
    self = [super init];
    if (self)
    {
        _identifier = identifier;
        _syncState = syncState;
        _error = error;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
      return YES;
    }
    
    if (![object isKindOfClass:[DMEFileListAccount class]])
    {
        return NO;
    }
    
    DMEFileListAccount *other = (DMEFileListAccount *)object;
    return [self.identifier isEqualToString:other.identifier] && self.syncState == other.syncState && ((self.error == nil && other.error == nil) || ([self.error isEqualToDictionary:other.error]));
}

- (NSUInteger)hash
{
    return self.identifier.hash ^ self.syncState ^ self.error.hash;
}

- (NSString *)syncStateString
{
    return [DMEFileList syncStateStringFromState:self.syncState];
}

- (NSString *)description
{
    NSString *syncStateString = [DMEFileList syncStateStringFromState:_syncState];
    
    return [NSString stringWithFormat:@"<%@: %p, identifier: %@, syncState: %@, error: %@>",
            NSStringFromClass([self class]), self, _identifier, syncStateString, _error ?: @"none"];
}

@end


