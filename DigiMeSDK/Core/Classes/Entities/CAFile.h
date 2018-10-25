//
//  CAFile.h
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAFileObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CAFile : NSObject

+ (CAFile *)deserialize:(NSData *)data fileId:(NSString *)fileId error:(NSError **)error;

/**
 -init unavailable. Use -initWithFileId:

 @return instancetype
 */
- (instancetype)init NS_UNAVAILABLE;


/**
 Designated object initializer.

 @param fileId NSString
 @return instancetype
 */
- (instancetype)initWithFileId:(NSString *)fileId NS_DESIGNATED_INITIALIZER;


/**
 Parses content and enriches this object.

 @param content NSArray.
 */
- (void)populateWithContent:(NSArray *)content;


/**
 File Identifier. This value is returned from the file list.
 */
@property (nonatomic, strong, readonly) NSString *fileId;


/**
 Serialized representation of the file's json.
 */
@property (nullable, nonatomic, strong, readonly) NSArray *json;


/**
 Array of CAFileObjects found in the file.
 */
@property (nullable, nonatomic, strong, readonly) NSArray<CAFileObject *> *objects;

NS_ASSUME_NONNULL_END

@end
