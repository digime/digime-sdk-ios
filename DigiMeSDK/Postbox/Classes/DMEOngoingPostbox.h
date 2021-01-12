//
//  DMEOngoingPostbox.h
//  DigiMeSDK
//
//  Created on 08/01/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

#import "DMEPostbox.h"

@class DMEOAuthToken;

NS_ASSUME_NONNULL_BEGIN

/**
 A Postbox with ongoing access to user's library
 */
@interface DMEOngoingPostbox : DMEPostbox

/**
 The OAuth token used for continued consent to push data. This is required in order to post data to the Postbox without digi.me client app involvement.
 */
@property (nonatomic, copy, readonly) DMEOAuthToken *oAuthToken;

/**
 Designated initialiser for the ongoing Postbox.

 @param sessionKey An active Consent Access session key.
 @param postboxId The ID of the Postbox in question.
 @param oAuthToken The OAuth token used for continued consent to push data.
 @return An initialised Postbox object.
 */
- (instancetype)initWithSessionKey:(NSString *)sessionKey postboxId:(NSString *)postboxId oAuthToken:(DMEOAuthToken *)oAuthToken NS_DESIGNATED_INITIALIZER;

/// Convenience initializer which creates an ongoing Postbox by coping another Postbox and adding the OAuth token
/// @param postbox The Postbox to copy
/// @param oAuthToken The OAuth token used for continued consent to push data.
- (instancetype)initWithPostbox:(DMEPostbox *)postbox oAuthToken:(DMEOAuthToken *)oAuthToken;

/// Creates a copy of this Postbox with updated session key
/// @param sessionKey An active Consent Access session key.
- (DMEOngoingPostbox *)updatedPostboxWithSessionKey:(NSString *)sessionKey;

- (instancetype)initWithSessionKey:(NSString *)sessionKey andPostboxId:(NSString *)postboxId NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
