//
//  DMEClient+GuestConsent.h
//  DigiMeSDK
//
//  Created on 22/11/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEClient.h"

@interface DMEClient (GuestConsent)

@property (nonatomic) BOOL useGuestConsent;

- (void)startWithGuestConsent;
- (void)startWithGuestConsentWithCompletion:(AuthorizationCompletionBlock)completion;

@end
