//
//  DMEFiles.h
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMEFiles : NSObject

/**
 -init unavailable. Use -initWithFileIds:

 @return instancetype
 */
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;


/**
 Designated object initializer.

 @param fileIds NSArray of file ids.
 @return instancetype.
 */
- (instancetype)initWithFileIds:(NSArray *)fileIds NS_DESIGNATED_INITIALIZER;


/**
 Array of fileIds.
 */
@property (nonatomic, strong, readonly) NSArray<NSString *> *fileIds;

@end

NS_ASSUME_NONNULL_END
