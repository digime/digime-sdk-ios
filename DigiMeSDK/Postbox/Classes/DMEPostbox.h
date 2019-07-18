//
//  DMEPostbox.h
//  DigiMeSDK
//
//  Created on 25/06/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMEPostbox : NSObject

/**
 The key for the CA session. This is required in order to post data to the Postbox.
 */
@property (nonatomic, copy, readonly) NSString *sessionKey;

/**
 The ID of the Postbox.
 */
@property (nonatomic, copy, readonly) NSString *postboxId;

/**
 The RSA public key in .pem format.
 */
@property (nonatomic, strong, readonly, nullable) NSString *publicKey;


/**
 Symetric RSA2048 public key used to encrypt data being sent to the Postbox.
 This is not populated automatically, and will require you fetch the public key yourself.
 */
@property (nonatomic, copy, nullable) NSString *postboxRSAPublicKey;

- (instancetype)init NS_UNAVAILABLE;

/**
 Designated initialiser for the Postbox.

 @param sessionKey A active Consent Access session key.
 @param postboxId The ID of the Postbox in question.
 @return An initialised Postbox object.
 */
- (instancetype)initWithSessionKey:(NSString *)sessionKey andPostboxId:(NSString *)postboxId NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
