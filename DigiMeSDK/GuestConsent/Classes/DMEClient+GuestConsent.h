//
//  DMEClient+GuestConsent.h
//  DigiMeSDK
//
//  Created on 22/11/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMEClient (GuestConsent)

/**
 Initializes contract authentication. This will attempt to create a session and then either redirect
 to the digi.me application (if installed) or present options for user to choose a one-time share or download the digi.me app.
 
 @param completion Block called when authorization has completed
 */
- (void)authorizeGuestWithCompletion:(AuthorizationCompletionBlock)completion;

/**
 Initializes contract authentication with custom scope. This will attempt to create a session and then either redirect
 to the digi.me application (if installed) or present options for user to choose a one-time share or download the digi.me app.

 @param scope Custom scope that will be applied to available data
 @param completion Block called when authorization has completed
 */
- (void)authorizeGuestWithScope:(nullable id<DMEDataRequest>)scope completion:(AuthorizationCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
