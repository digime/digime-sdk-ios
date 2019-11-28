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
    AuthErrorGeneral    = 1, //general error
    AuthErrorCancelled  = 5, //authorization cancelled
    AuthErrorInvalidSession = 7, //invalid session
    AuthErrorInvalidSessionKey = 10, //session key returned by digi.me app is invalid
    AuthErrorScopeOutOfBounds = 11, // requested scope is out of bounds of Contract scope.
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
