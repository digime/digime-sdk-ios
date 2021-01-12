//
//  DMECrypto.h
//  DigiMeSDK
//
//  Created on 25/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEOAuthToken.h"

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
 Create and sign the new preAuthorization JWT with a private key
 
 @param appId NSString - 3rd party application identifier.
 @param contractId NSString - CA Contract identifier.
 @param privateKeyHex NSString - 3rd party RSA private key in hex format.
 @return NSString - JSON Web Token signed with PS512 algorithm.
 */
+ (NSString *)createPreAuthorizationJwtWithAppId:(NSString *)appId contractId:(NSString *)contractId privateKey:(NSString *)privateKeyHex;

/**
 Create and sign the new preAuthorization JWT with a private key
 
 @param appId NSString - 3rd party application identifier.
 @param contractId NSString - CA Contract identifier.
 @param privateKeyHex NSString - 3rd party RSA private key in hex format.
 @param publicKeyHex NSString - 3rd party RSA public key in hex format. Optional parameter.
 @return NSString - JSON Web Token signed with PS512 algorithm.
 */
+ (NSString *)createPreAuthorizationJwtWithAppId:(NSString *)appId contractId:(NSString *)contractId privateKey:(NSString *)privateKeyHex publicKey:(nullable NSString *)publicKeyHex;

/**
 Validates and extracts preAuthorization JWT with a public key.
 
 @param jwt NSString - JWT token to validate and decode.
 @param publicKey NSString - digi.me RSA public key in pem format.
 @return NSString - decoded and validated JSON Web Token.
 */
+ (NSString *)preAuthCodeFromJwt:(NSString *)jwt publicKey:(NSString *)publicKey;

/**
 Creates and signs the new authorization JWT with a private key.
 
 @param authCode - authentication code.
 @param appId NSString - 3rd party application identifier.
 @param contractId NSString - CA Contract identifier.
 @param privateKeyHex NSString - 3rd party RSA private key in hex format.
 @return NSString - JSON Web Token signed with PS512 algorithm.
 */
+ (NSString *)createAuthJwtWithAuthCode:(NSString *)authCode appId:(NSString *)appId contractId:(NSString *)contractId privateKey:(NSString *)privateKeyHex;

/**
 Creates and signs the new authorization JWT with a private key.
 
 @param authCode - authentication code.
 @param appId NSString - 3rd party application identifier.
 @param contractId NSString - CA Contract identifier.
 @param privateKeyHex NSString - 3rd party RSA private key in hex format.
 @param publicKeyHex NSString -  3rd party RSA public key in hex format. Optional parameter.
 @return NSString - JSON Web Token signed with PS512 algorithm.
 */
+ (NSString *)createAuthJwtWithAuthCode:(NSString *)authCode appId:(NSString *)appId contractId:(NSString *)contractId privateKey:(NSString *)privateKeyHex publicKey:(nullable NSString *)publicKeyHex;

/**
 Creates and signs the new authorization JWT with a private key.
 
 @param accessToken - OAuth access token..
 @param appId NSString - 3rd party application identifier.
 @param contractId NSString - CA Contract identifier.
 @param privateKeyHex NSString - 3rd party RSA private key in hex format.
 @return NSString - JSON Web Token signed with PS512 algorithm.
 */
+ (NSString *)createDataTriggerJwtWithAccessToken:(NSString *)accessToken appId:(NSString *)appId contractId:(NSString *)contractId sessionKey:(NSString *)sessionKey privateKey:(NSString *)privateKeyHex;

/**
 Create and sign the new access token JWT with a private key
 
 @param accessToken - OAuth access token.
 @param appId NSString - 3rd party application identifier.
 @param contractId NSString - CA Contract identifier.
 @param privateKeyHex NSString - 3rd party RSA private key in hex format.
 @param publicKeyHex NSString -  3rd party RSA public key in hex format. Optional parameter.
 @return NSString - JSON Web Token signed with PS512 algorithm.
 */
+ (NSString *)createDataTriggerJwtWithAccessToken:(NSString *)accessToken appId:(NSString *)appId contractId:(NSString *)contractId sessionKey:(NSString *)sessionKey privateKey:(NSString *)privateKeyHex publicKey:(nullable NSString *)publicKeyHex;

/**
 Create and sign the new refresh token JWT with a private key
 
 @param refreshToken - OAuth refresh token.
 @param appId NSString - 3rd party application identifier.
 @param contractId NSString - CA Contract identifier.
 @param privateKeyHex NSString - 3rd party RSA private key in hex format.
 @return NSString - JSON Web Token signed with PS512 algorithm.
 */
+ (NSString *)createRefreshJwtWithRefreshToken:(NSString *)refreshToken appId:(NSString *)appId contractId:(NSString *)contractId privateKey:(NSString *)privateKeyHex;

/**
 Create and sign the new refresh token JWT with a private key
 
 @param refreshToken - OAuth refresh token.
 @param appId NSString - 3rd party application identifier.
 @param contractId NSString - CA Contract identifier.
 @param privateKeyHex NSString - 3rd party RSA private key in hex format.
 @param publicKeyHex NSString -  3rd party RSA public key in hex format. Optional parameter.
 @return NSString - JSON Web Token signed with PS512 algorithm.
 */
+ (NSString *)createRefreshJwtWithRefreshToken:(NSString *)refreshToken appId:(NSString *)appId contractId:(NSString *)contractId privateKey:(NSString *)privateKeyHex publicKey:(nullable NSString *)publicKeyHex;

/**
 Create and sign the Postbox push JWT with a private key

 @param accessToken - OAuth access token.
 @param appId NSString - 3rd party application identifier.
 @param contractId NSString - CA Contract identifier.
 @param iv NSData - The initialization vector
 @param metadata NSString - The encrypted metadata
 @param sessionKey NSSTring - The session key
 @param symmetricalKey NSString - The encrypted symetrical key
 @param privateKeyHex NSString - 3rd party RSA private key in hex format.
 @param publicKeyHex NSString -  3rd party RSA public key in hex format. Optional parameter.
 */
+ (NSString *)createPostboxPushJwtWithAccessToken:(nullable NSString *)accessToken appId:(NSString *)appId contractId:(NSString *)contractId initializationVector:(NSData *)iv metadata:(NSString *)metadata sessionKey:(NSString *)sessionKey symmetricalKey:(NSString *)symmetricalKey privateKey:(NSString *)privateKeyHex publicKey:(nullable NSString *)publicKeyHex;

@end

NS_ASSUME_NONNULL_END
