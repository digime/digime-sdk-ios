//
//  DMEFilesDeserializer.h
//  DigiMeSDK
//
//  Created on 30/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEFiles.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMEFilesDeserializer : NSObject


/**
 Deserializes JSON content into DMEFiles object.

 @param jsonData NSData
 @param error NSError
 @return DMEFiles object
 */
+ (nullable DMEFiles *)deserialize:(NSData *)jsonData error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
