//
//  DMESessionDeserializer.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMESession.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMESessionDeserializer : NSObject


/**
 Deserializes JSON response data into DMESession

 @param jsonData NSData
 @param error NSError
 @return DMESession
 */
+ (nullable DMESession *)deserialize:(NSData *)jsonData error:(NSError * __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
