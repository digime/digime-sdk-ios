//
//  NSError+Auth.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const DME_AUTHORIZATION_ERROR = @"me.digi.authorization";

typedef NS_ENUM(NSInteger, AuthError) {
    AuthErrorGeneral    = 1, //general error
    AuthErrorAppId      = 2, //app id not set
    AuthErrorContract   = 3, //contract id not set
    AuthErrorPrivateHex = 4, //private hex not set
    AuthErrorCancelled  = 5, //authorization cancelled
    AuthErrorInProgress = 6, //authorization already in progress
    AuthErrorInvalidSession = 7, //invalid session
    AuthErrorAppNotFound = 8, //Digi.me app not installed
    AuthErrorNotOnboarded = 9, //Digi.me app is not connected to library
    AuthErrorInvalidSessionKey = 10, //session key returned by Digi.me app is invalid
};

@interface NSError (Auth)

+ (NSError *)authError:(AuthError)authError;

@end
