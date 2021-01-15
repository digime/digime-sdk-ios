//
//  DMEPushClient.h
//  DigiMeSDK
//
//  Created on 01/08/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEClient.h"
#import "DMEClientCallbacks.h"

@class DMEPushConfiguration;
@class DMEPostbox;

NS_ASSUME_NONNULL_BEGIN

/**
 Client object used for returning data to the user, following their consent.
 */
@interface DMEPushClient: DMEClient

- (instancetype)initWithConfiguration:(DMEPushConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

#pragma mark - One-off Postbox

/**
 Hands off to the DigiMe app to request a Postbox that can be used to send data to a user's library.
 
 @param completion Block called on main thread when postbox creation finished
 */
- (void)createPostboxWithCompletion:(DMEPostboxCreationCompletion)completion;

/**
 Pushes data to user's Postbox.
 
 Once data is in the user's Postbox, it will need importing into the user's library.
 This can be accomplished by simply opening the digi.me client app by calling `openDMEAppForPostboxImport`.
 
 @param postbox The ongoing Postbox to push data to
 @param metadata The metadata describing the data being pushed
 @param data The data to push to user's library
 @param completion Block called on main thread when pushing data has completed
 */
- (void)pushDataToPostbox:(DMEPostbox *)postbox
                 metadata:(NSData *)metadata
                     data:(NSData *)data
               completion:(DMEPostboxDataPushCompletion)completion;

/**
 After you have pushed data into a Postbox, you can trigger the digi.me app to then import the data into the user library.
 This only applies to one-off Postboxes, not for ongoing Postboxes.
 */
- (void)openDMEAppForPostboxImport;

#pragma mark - Ongoing Postbox

/**
 Initializes ongoing contract authentication and intially requests a Postbox that can be used to send data to a user's library. Once user has given consent in digi.me app all subsequent data push calls will be done without digi.me client app involvement.
 
 This authorization flow enables 3rd parties to access protected resources, without requiring users to disclose their digi.me credentials to the consumers.
 
 On first call (when `existingPostbox` is `nil`), digi.me client app is opened to request consent. If granted, then completion will contain postbox.
 
 On subsequent calls, when `existingPostbox` is passed, a new session is created (if necessary) and a new postbox object is returned in completion.
 
 The caller is expected to retain the ongoing postbox to allow continued access to push data to user's library.
 
 @param postbox An existing ongoing Postbox (if available)
 @param completion Block called on main thread when authorization has completed
 */
- (void)authorizeOngoingPostboxWithExistingPostbox:(nullable DMEOngoingPostbox *)postbox completion:(DMEOngoingPostboxCompletion)completion;

/**
 Pushes data to user's Postbox and automaitcally imports the
 
 Upon completion, the returned Postbox should be retained in place of the one passed in as it may contain updated OAuth tokens if they needed refreshing.
 
 If the tokens have expired and cannot be refreshed, the digi.me client app may be opened to request user consent and new tokens will be issued.
 
 @param postbox The ongoing Postbox to push data to
 @param metadata The metadata describing the data being pushed
 @param data The data to push to user's library
 @param completion Block called on main thread when pushing data has completed
 */
- (void)pushDataToOngoingPostbox:(DMEOngoingPostbox *)postbox
                        metadata:(NSData *)metadata
                            data:(NSData *)data
                      completion:(DMEOngoingPostboxCompletion)completion;

@end

NS_ASSUME_NONNULL_END
