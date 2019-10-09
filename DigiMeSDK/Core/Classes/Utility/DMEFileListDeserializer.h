//
//  DMEFileListDeserializer.h
//  DigiMeSDK
//
//  Created on 13/08/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEFileList.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMEFileListDeserializer : NSObject

/**
 Deserializes JSON content into DMEFileList object.

 @param jsonData NSData
 @param error NSError
 @return DMEFileList object
 */
+ (nullable DMEFileList *)deserialize:(NSData *)jsonData error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
