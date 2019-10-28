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
        _syncState = [self fileSyncStateForState:_syncStateString];
    }
    
    return self;
}

- (NSArray<NSString *> *)fileIds
{
    return [self.files valueForKey:@"name"];
}

- (DMEFileSyncState)fileSyncStateForState:(NSString * _Nullable )state
{
    if ([state isEqualToString:@"running"])
    {
        return DMEFileSyncStateRunning;
    }
    else if ([state isEqualToString:@"pending"])
    {
        return DMEFileSyncStatePending;
    }
    else if ([state isEqualToString:@"partial"])
    {
        return DMEFileSyncStatePartial;
    }
    else if ([state isEqualToString:@"completed"])
    {
        return DMEFileSyncStateCompleted;
    }
    else
    {
        return DMEFileSyncStateUnknown;
    }
}

@end
