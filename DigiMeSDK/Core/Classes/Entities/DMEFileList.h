//
//  DMEFileList.h
//  DigiMeSDK
//
//  Created on 13/08/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class DMEFileListItem;

/**
 Sync status enum.
 */
typedef NS_ENUM(NSInteger, DMEFileSyncStatus)
{
    DMEFileSyncStatusUnknown = 0,
    DMEFileSyncStatusRunning,
    DMEFileSyncStatusPending,
    DMEFileSyncStatusPartial,
    DMEFileSyncStatusCompleted
};

/**
 Serialized representation of the JSON object returned by getFileList endpoint.
 */
@interface DMEFileList : NSObject

/**
 -init unavailable. Use -initWithFileIds:

 @return instancetype
 */
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;


/**
 Designated object initializer.

 @param json NSDictionary representation of file list.
 @return instancetype.
 */
- (instancetype)initWithJSON:(NSDictionary *)json NS_DESIGNATED_INITIALIZER;


/**
 Array of fileIds.
 */
@property (nonatomic, strong, readonly) NSArray<NSString *> *fileIds;

@property (nonatomic, strong, readonly) NSArray<DMEFileListItem *> *files;

@property (nonatomic, readonly) DMEFileSyncStatus syncStatus;

@property (nonatomic, strong, readonly) NSString *syncStatusString;

@end

NS_ASSUME_NONNULL_END
