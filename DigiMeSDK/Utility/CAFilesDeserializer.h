//
//  CAFilesDeserializer.h
//  DigiMeSDK
//
//  Created on 30/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAFiles.h"

NS_ASSUME_NONNULL_BEGIN

@interface CAFilesDeserializer : NSObject


/**
 Deserializes JSON content into CAFiles object.

 @param jsonData NSData
 @param error NSError
 @return CAFiles object
 */
+ (nullable CAFiles *)deserialize:(NSData *)jsonData error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
