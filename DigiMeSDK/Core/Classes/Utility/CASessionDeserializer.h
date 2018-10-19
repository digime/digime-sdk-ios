//
//  CASessionDeserializer.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CASession.h"

NS_ASSUME_NONNULL_BEGIN

@interface CASessionDeserializer : NSObject


/**
 Deserializes JSON response data into CASession

 @param jsonData NSData
 @param error NSError
 @return CASession
 */
+ (nullable CASession *)deserialize:(NSData *)jsonData error:(NSError * __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
