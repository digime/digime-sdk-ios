//
//  CADataDecryptor.h
//  DigiMeSDK
//
//  Created on 05/02/2018.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CADataDecryptor : NSObject

/**
Decrypts encrypted JSON data using private key.

@param jsonData NSData - encrypted JSON data
@param error NSError
@return NSData if decryption was successful, otherwise nil.
*/
+ (nullable NSData *)decrypt:(NSData *)jsonData error:(NSError * __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
