//
//  DMECrypto.h
//  DigiMeSDK
//
//  Created on 25/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEOAuthObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMECrypto : NSObject

/**
 Decrypts encrypted data using private key data from specified configuration.

 @param encryptedData NSData
 @param contractId The contract identifier
 @param keyHex The private hex key with which data can be decrypted
 @return NSData - decrypted data or nil if decryption failed.
 */
+ (nullable NSData *)getDataFromEncryptedBytes:(NSData *)encryptedData contractId:(NSString *)contractId privateKeyHex:(NSString *)keyHex;

/**
 Encrypt data using AES256 algorithm.
 
 @param keyData NSData
 @param ivData NSData
 @param data NSData
 @param error NSError
 @return NSData - encrypted data or nil if encryption failed.
 */

+ (nullable NSData *)encryptAes256UsingKey:(NSData *)keyData initializationVector:(NSData *)ivData data:(NSData *)data error:(NSError * __autoreleasing * _Nullable)error;

/**
 Decrypt data using AES256 algorithm.

 @param keyData NSData
 @param ivData NSData
 @param data NSData
 @param error NSError
 @return NSData - decrypted data or nil if decryption failed.
 */
+ (nullable NSData *)decryptAes256UsingKey:(NSData *)keyData initializationVector:(NSData *)ivData data:(NSData *)data error:(NSError * __autoreleasing *)error;

/**
 Encrypts metadata for Postbox with AES encryption
 
 @param metadata NSData
 @param symmetricalKey NSData
 @param iv NSData
 @return NSString - AES encrypted metadata to push to postbox in Base64 encoding.
 */
+ (NSString *)encryptMetadata:(NSData *)metadata symmetricalKey:(NSData *)symmetricalKey initializationVector:(NSData *)iv;

/**
 Encrypts data for Postbox with AES encryption
 
 @param payload NSData
 @param symmetricalKey NSData
 @param iv NSData
 @return NSString - AES encrypted data to push to postbox in a hexadecimal representation.
 */
+ (NSData *)encryptData:(NSData *)payload symmetricalKey:(NSData *)symmetricalKey initializationVector:(NSData *)iv;

/**
 Encrypts Symmetrical Key for Postbox with RSA public key and return it as Base64 encoded.
 
 @param symmetricalKey NSData
 @param contractId The contract identifier.
 @param publicKey NSString
 */
+ (NSString *)encryptSymmetricalKey:(NSData *)symmetricalKey rsaPublicKey:(NSString *)publicKey contractId:(NSString *)contractId;

/**
 Encrypt data using RSA public key.
 
 @param dataToEncrypt NSData
 @param publicKey NSData
 @return NSData - encrypted data or nil if encryption failed.
 */
+ (NSData *)encryptLargeData:(NSData *)dataToEncrypt publicKey:(SecKeyRef)publicKey;

/**
 Decrypt data using RSA private key.
 
 @param dataToDecrypt NSData
 @param privateKey NSData
 @return NSData - decrypted data or nil if decryption failed.
 */
+ (NSData *)decryptLargeData:(NSData *)dataToDecrypt privateKey:(SecKeyRef)privateKey;

/**
 Create and sign the new preauthorisation JWT with a private key
 
 @param appId NSString - 3rd party application identifier.
 @param contractId NSString - CA Contract identifier.
 @param privateKeyHexString NSString - 3rd party RSA private key in hex format.
 @param publicKeyHexString NSString - 3rd party RSA public key in hex format. Optional parameter.
 @return NSString - JSON Web Token signed with PS512 algorithm.
 */
+ (NSString *)createOngoingAccessPreauthorizationCodeWithAppId:(NSString *)appId contractId:(NSString *)contractId privateKey:(NSString *)privateKeyHexString publicKey:(nullable NSString *)publicKeyHexString;

/**
 Validate and extract preauthorisation JWT with a public key.
 
 @param authorityPublicKeyPem NSString - digi.me RSA public key in pem format.
 @param preauthToken NSString - JWT token to validate and decode.
 @return NSString - decoded and validated JSON Web Token.
 */
+ (NSString *)validateAndDecodeOngoingAccessPreauthorizationCodeWithAuthorityPublicKeyPem:(NSString *)authorityPublicKeyPem preauthToken:(NSString *)preauthToken;

/**
 Create and sign the new authorisation JWT with a private key
 
 @param authCode - authentication code.
 @param appId NSString - 3rd party application identifier.
 @param contractId NSString - CA Contract identifier.
 @param privateKeyHexString NSString - 3rd party RSA private key in hex format.
 @param publicKeyHexString NSString -  3rd party RSA public key in hex format. Optional parameter.
 @return NSString - JSON Web Token signed with PS512 algorithm.
 */
+ (NSString *)createOngoingAccessAuthorizationCodeWithAuthCode:(NSString *)authCode appId:(NSString *)appId contractId:(NSString *)contractId privateKey:(NSString *)privateKeyHexString publicKey:(nullable NSString *)publicKeyHexString;

/**
Create and sign the new access token JWT with a private key

@param accessToken - OAuth access token..
@param appId NSString - 3rd party application identifier.
@param contractId NSString - CA Contract identifier.
@param privateKeyHexString NSString - 3rd party RSA private key in hex format.
@param publicKeyHexString NSString -  3rd party RSA public key in hex format. Optional parameter.
@return NSString - JSON Web Token signed with PS512 algorithm.
*/
+ (NSString *)createDataTriggerToken:(NSString *)accessToken appId:(NSString *)appId contractId:(NSString *)contractId sessionKey:(NSString *)sessionKey privateKey:(NSString *)privateKeyHexString publicKey:(nullable NSString *)publicKeyHexString ;

/**
Create and sign the new refresh token JWT with a private key

@param refreshToken - OAuth refresh token..
@param appId NSString - 3rd party application identifier.
@param contractId NSString - CA Contract identifier.
@param privateKeyHexString NSString - 3rd party RSA private key in hex format.
@param publicKeyHexString NSString -  3rd party RSA public key in hex format. Optional parameter.
@return NSString - JSON Web Token signed with PS512 algorithm.
*/
+ (NSString *)createRefreshToken:(NSString *)refreshToken appId:(NSString *)appId contractId:(NSString *)contractId privateKey:(NSString *)privateKeyHexString publicKey:(nullable NSString *)publicKeyHexString;

@end

NS_ASSUME_NONNULL_END
