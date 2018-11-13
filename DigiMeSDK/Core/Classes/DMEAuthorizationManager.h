//
//  DMEAuthorizationManager.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEClientCallbacks.h"
#import "DMEAppCommunicator.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMEAuthorizationManager : NSObject <DMEAppCallbackHandler>

/**
 Initiates contract authorization launching Digi.me App if there is a valid active session.
 
 @param completion AuthorizationCompletionBlock
 */
- (void)beginAuthorizationWithCompletion:(AuthorizationCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
