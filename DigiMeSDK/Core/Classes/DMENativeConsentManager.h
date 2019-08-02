//
//  DMENativeConsentManager.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEClientCallbacks.h"
#import "DMEAppCommunicator+Private.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMENativeConsentManager : NSObject <DMEAppCallbackHandler>

/**
 Initiates contract authorization launching Digi.me App if there is a valid active session.
 
 @param completion AuthorizationCompletionBlock
 */
- (void)beginAuthorizationWithCompletion:(DMEAuthorizationCompletion)completion;

@end

NS_ASSUME_NONNULL_END
