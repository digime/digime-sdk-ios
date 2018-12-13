//
//  CADataDecryptor.h
//  DigiMeSDK
//
//  Created on 05/02/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CADataDecryptor : NSObject

/**
Decrypts encrypted JSON data using private key.

@param fileContent An object containing encrypted or unencrypted data
@param error NSError
@return Decrypted data if decryption was successful, otherwise nil.
*/
+ (nullable NSData *)decryptFileContent:(id)fileContent error:(NSError * _Nullable __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
