//
//  DMEClientDelegate.h
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CASession.h"
#import "NSError+SDK.h"
#import "NSError+Auth.h"
#import "NSError+API.h"
#import "CAAccounts.h"
#import "CAFiles.h"
#import "CAFile.h"

#pragma once

NS_ASSUME_NONNULL_BEGIN

@protocol DMEClientDelegate <NSObject>

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


/**
 Executed when DMEClient has retrieved file list available for the contract.

 @param files CAFiles.
 */
- (void)clientRetrievedFileList:(CAFiles *)files;


/**
 Executed DMEClient failed to retrieve contract file list.

 @param error NSError.
 */
- (void)clientFailedToRetrieveFileList:(NSError *)error;


/**
 Executed when file content has been retrieved.

 @param file CAFile object.
 */
- (void)fileRetrieved:(CAFile *)file;


/**
 Executed when file could not be retrieved

 @param fileId Id of the file that failed
 @param error NSError
 */
- (void)fileRetrieveFailed:(NSString *)fileId error:(NSError *)error;


/**
 Executed when DMEClient has retrieved accounts available for the contract

 @param accounts available accounts
 */
- (void)accountsRetrieved:(CAAccounts *)accounts;


/**
 Executed when accounts could not be retrieved

 @param error error NSError
 */
- (void)accountsRetrieveFailed:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
