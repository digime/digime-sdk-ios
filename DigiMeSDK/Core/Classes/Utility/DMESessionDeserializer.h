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

 @param jsonData The JSON data describing the session
 @param sessionManager The session manager owning the session
 @param contractId The identifier of the contract the session relates to
 @param error If deserialization fails, contains the error describing the failure. nil if deserialization is successful
 @return A new session object if deserialization is successful, otherwise nil
 */
+ (nullable DMESession *)deserialize:(NSData *)jsonData sessionManager:(DMESessionManager *)sessionManager contractId:(NSString *)contractId error:(NSError * __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
