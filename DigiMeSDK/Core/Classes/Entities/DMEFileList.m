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
@property (nonatomic, readwrite) DMEFileSyncStatus syncStatus;

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
        _syncStatusString = json[@"status"][@"state"];
        _syncStatus = [self syncStatusForState:_syncStatusString];
    }
    
    return self;
}

- (NSArray<NSString *> *)fileIds
{
    return [self.files valueForKey:@"name"];
}

- (DMEFileSyncStatus)syncStatusForState:(NSString * _Nullable )state
{
    if ([state isEqualToString:@"running"])
    {
        return DMEFileSyncStatusRunning;
    }
    else if ([state isEqualToString:@"pending"])
    {
        return DMEFileSyncStatusPending;
    }
    else if ([state isEqualToString:@"partial"])
    {
        return DMEFileSyncStatusPartial;
    }
    else if ([state isEqualToString:@"completed"])
    {
        return DMEFileSyncStatusCompleted;
    }
    else
    {
        return DMEFileSyncStatusUnknown;
    }
}

@end
