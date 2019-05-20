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
 @return NSData - rundom bytes for the specified length.
 */
- (NSData *)getRandomUnsignedCharacters:(int)length;

/**
 Encrypt metadata for Postbox with AES encryption
 
 @param symmetricalKey NSData
 @param iv NSData
 @param metadata NSData
 @return NSString - AES encrypted metadata to push to postbox in Base64 encoding.
 */
- (NSString *)preparePostboxMetadataWithKey:(NSData *)symmetricalKey initializationVector:(NSData *)iv metadata:(NSData *)metadata;

/**
 Encrypt data for Postbox with AES encryption
 
 @param symmetricalKey NSData
 @param iv NSData
 @param data NSData
 @return NSString - AES encrypted data to push to postbox in a hexadecimal representation.
 */
- (NSData *)preparePostboxDataWithKey:(NSData *)symmetricalKey initializationVector:(NSData *)iv dataToPush:(NSData *)data;

/**
 Encrypt Symmetrical Key for Postbox with RSA public key and return it as Base64 encoded.
 
 @param dataToEncrypt NSData
 @param publicKey NSString
 */
- (NSString *)preparePostboxSymmetricalKeyWithData:(NSData *)dataToEncrypt rsaPublicKeyForEncryption:(NSString *)publicKey;

@end

NS_ASSUME_NONNULL_END
