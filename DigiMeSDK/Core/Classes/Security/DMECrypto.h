//
//  DMECrypto.h
//  DigiMeSDK
//
//  Created on 25/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
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
 @return NSData - decrypted data or nil if decryption failed.
 */
- (nullable NSData *)getDataFromEncryptedBytes:(NSData *)encryptedData privateKeyData:(NSData *)privateKeyData;


/**
 Decrypt data using AES256 algorithm.

 @param keyData NSData
 @param ivData NSData
 @param data NSData
 @param error NSError
 @return NSData - decrypted data or nil if decryption failed.
 */
- (nullable NSData *)decryptAes256UsingKey:(NSData *)keyData initializationVector:(NSData *)ivData data:(NSData *)data error:(NSError * __autoreleasing *)error;

/**
 Generates random data using length as a parameter.
 
 @param length int
 @return NSData - random bytes for the specified length.
 */
- (NSData *)getRandomUnsignedCharacters:(int)length;

/**
 Encrypts metadata for Postbox with AES encryption
 
 @param metadata NSData
 @param symmetricalKey NSData
 @param iv NSData
 @return NSString - AES encrypted metadata to push to postbox in Base64 encoding.
 */
- (NSString *)encryptMetadata:(NSData *)metadata symmetricalKey:(NSData *)symmetricalKey initializationVector:(NSData *)iv;

/**
 Encrypts data for Postbox with AES encryption
 
 @param payload NSData
 @param symmetricalKey NSData
 @param iv NSData
 @return NSString - AES encrypted data to push to postbox in a hexadecimal representation.
 */
- (NSData *)encryptData:(NSData *)payload symmetricalKey:(NSData *)symmetricalKey initializationVector:(NSData *)iv;

/**
 Encrypts Symmetrical Key for Postbox with RSA public key and return it as Base64 encoded.
 
 @param symmetricalKey NSData
 @param publicKey NSString
 */
- (NSString *)encryptSymmetricalKey:(NSData *)symmetricalKey rsaPublicKey:(NSString *)publicKey;

@end

NS_ASSUME_NONNULL_END
