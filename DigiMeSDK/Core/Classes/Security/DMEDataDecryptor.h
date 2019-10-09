//
//  DMEDataDecryptor.h
//  DigiMeSDK
//
//  Created on 05/02/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DMEPullConfiguration;

@interface DMEDataDecryptor : NSObject

/**
 The initializer

 @param configuration The configuration for which the decryptor can decrypt
 @return A new instance of DMEDataDecryptor
 */
- (instancetype)initWithConfiguration:(DMEPullConfiguration *)configuration NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
Decrypts encrypted JSON data using private key.

@param fileContent An object containing encrypted or unencrypted data
@param error NSError
@return Decrypted data if decryption was successful, otherwise nil.
*/
- (nullable NSData *)decryptFileContent:(id)fileContent error:(NSError * _Nullable __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
