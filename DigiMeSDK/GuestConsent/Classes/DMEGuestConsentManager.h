//
//  DMEGuestConsentManager.h
//  DigiMeSDK
//
//  Created on 22/11/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEAppCommunicator.h"
#import "DMEClientCallbacks.h"

@class DMEClientConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface DMEGuestConsentManager : NSObject <DMEAppCallbackHandler>

- (void)requestGuestConsentWithCompletion:(AuthorizationCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
