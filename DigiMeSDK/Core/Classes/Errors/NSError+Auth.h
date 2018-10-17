//
//  NSError+Auth.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const DME_AUTHORIZATION_ERROR = @"me.digi.authorization";

typedef NS_ENUM(NSInteger, AuthError) {
    AuthErrorGeneral    = 1, //general error
    AuthErrorCancelled  = 5, //authorization cancelled
    AuthErrorInProgress = 6, //authorization already in progress
    AuthErrorInvalidSession = 7, //invalid session
    AuthErrorInvalidSessionKey = 10, //session key returned by Digi.me app is invalid
};

@interface NSError (Auth)

+ (NSError *)authError:(AuthError)authError;

@end

NS_ASSUME_NONNULL_END
