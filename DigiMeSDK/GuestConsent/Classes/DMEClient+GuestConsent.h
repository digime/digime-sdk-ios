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

- (void)authorizeGuest;
- (void)authorizeGuestWithCompletion:(AuthorizationCompletionBlock)completion;

@end
