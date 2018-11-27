//
//  DMEGuestConsentManager.h
//  DigiMeSDK
//
//  Created on 22/11/2018.
//  Copyright © 2018 me.digi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEAppCommunicator.h"
#import "DMEClientCallbacks.h"

@interface DMEGuestConsentManager : NSObject <DMEAppCallbackHandler>

- (void)requestGuestConsentWithBaseUrl:(NSString *)baseUrl withCompletion:(AuthorizationCompletionBlock)completion;

@end
