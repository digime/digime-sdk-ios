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
@class DMEFileListAccount;

/**
 Sync state enum.
 */
typedef NS_ENUM(NSInteger, DMEFileSyncState)
{
    DMEFileSyncStateUnknown = 0,
    DMEFileSyncStateRunning,
    DMEFileSyncStatePending,
    DMEFileSyncStatePartial,
    DMEFileSyncStateCompleted
};

/**
 Serialized representation of the JSON object returned by `getFileList` endpoint.
 */
@interface DMEFileList : NSObject

/**
 -init unavailable. Use -initWithJSON:

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

@property (nonatomic, readonly) DMEFileSyncState syncState;

@property (nonatomic, strong, readonly) NSString *syncStateString;

@property (nonatomic, strong, readonly) NSArray<DMEFileListAccount *> *accounts;

@end

/**
 Serialized representation of the account object embedded in the `getFileList` response.
 */
@interface DMEFileListAccount : NSObject
    
/**
 -init unavailable. Use -initWithIdentifier:syncState:error:

 @return instancetype
 */
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;


/**
 Designated object initializer.

 @param identifier account identifier
 @param syncState sync state of the account
 @param error error encountered while syncing account
 @return instancetype.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier syncState:(DMEFileSyncState)syncState error:(NSDictionary  * _Nullable)error NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, readonly) DMEFileSyncState syncState;
@property (nonatomic, strong, readonly, nullable) NSDictionary <NSString *, id> *error;

@end

NS_ASSUME_NONNULL_END
