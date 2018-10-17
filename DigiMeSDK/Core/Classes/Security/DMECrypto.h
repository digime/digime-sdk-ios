//
//  DMECrypto.h
//  DigiMeSDK
//
//  Created on 25/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMECryptoUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMECrypto : NSObject


/**
 Saves private key data securely

 @param privateKeyHex NSString
 @return YES if saved successfully, otherwise NO
 */
- (BOOL)addPrivateKeyHex:(NSString *)privateKeyHex;


/**
 Returns private key hex data, if it was previously saved.

 @return NSData - previously saved private hex key data or nil if none
 */
- (nullable NSData *)privateKeyHex;


/**
 Decrypts encrypted data using private key data.

 @param encryptedData NSData
 @param privateKeyData NSData
 @return NSData - decrypted data or nil if decryption failed
 */
- (nullable NSData *)getDataFromEncryptedBytes:(NSData *)encryptedData privateKeyData:(NSData *)privateKeyData;


/**
 Decrypt data using AES256 algorithm.

 @param keyData NSData
 @param ivData NSData
 @param data NSData
 @param error NSError
 @return NSData - decrypted data or nil if decryption failed
 */
- (nullable NSData *)decryptAes256UsingKey:(NSData *)keyData initializationVector:(NSData *)ivData data:(NSData *)data error:(NSError * __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
