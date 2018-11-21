//
//  DMEClientAuthorizationDelegate.h
//  Pods
//
//  Created on 09/07/2018.
//  Copyright © 2018 me.digi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CASession.h"
#import "NSError+SDK.h"
#import "NSError+Auth.h"
#import "NSError+API.h"

#pragma once

NS_ASSUME_NONNULL_BEGIN

@protocol DMEClientAuthorizationDelegate <NSObject>

@optional

/**
 Executed when session has been created.
 
 @param session Consent Access Session
 */
- (void)sessionCreated:(CASession *)session;


/**
 Executed when session creation has failed.
 
 @param error NSError
 */
- (void)sessionCreateFailed:(NSError *)error;


/**
 Executed when CA Contract has been successfully authorized.
 
 @param session Consent Access Session
 */
- (void)authorizeSucceeded:(CASession *)session;


/**
 Executed when CA Contract has been declined by the user.
 
 @param error NSError
 */
- (void)authorizeDenied:(NSError *)error;


/**
 Executed when CA Contract has been authorized, but failed for another reason.
 
 @param error NSError
 */
- (void)authorizeFailed:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
