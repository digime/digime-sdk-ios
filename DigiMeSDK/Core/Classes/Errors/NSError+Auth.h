//
//  NSError+Auth.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const DME_AUTHORIZATION_ERROR = @"me.digi.sdk.authorization";

/**
 Enum representing possible Authorization errors.
 */
typedef NS_ENUM(NSInteger, AuthError) {
    AuthErrorGeneral = 1, // general error
    AuthErrorCancelled = 5, // authorization cancelled
    AuthErrorInvalidSession = 7, //invalid session
    AuthErrorInvalidSessionKey = 10, //session key returned by digi.me app is invalid
    AuthErrorScopeOutOfBounds = 11, // requested scope is out of bounds of Contract scope.
    AuthErrorInvalidPCloud = 12, // invalid PCloud
    AuthErrorInvalidJWT = 13, // The provided JSON Web Token (JWT) is invalid
    AuthErrorInvalidRequest = 14, // JWT header|payload failed JSON schema validation
    AuthErrorInvalidRedirectUri = 15, // The redirect_uri (${redirectUri}) is invalid
    AuthErrorInvalidToken = 16, // The token (${tokenType}) is invalid
    AuthErrorInvalidGrant = 17, // The grant_type (${options.input}) is invalid, expected grant_type (${options.expected})
    AuthErrorInvalidClient = 18, // The client_id (${clientId}) is invalid
    AuthErrorInvalidTokenType = 19, // The token_type (${inputTokenType}) is invalid, expected token_type (${expectedTokenType})
};

/**
 Convenience category used to generate an error in `DME_AUTHORIZATION_ERROR` domain
 */
@interface NSError (Auth)

+ (NSError *)authError:(AuthError)authError;
+ (NSError *)authError:(AuthError)authError additionalInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)additionalInfo;
+ (NSError *)authError:(AuthError)authError reference:(nullable NSString *)errorReference;

@end

NS_ASSUME_NONNULL_END
