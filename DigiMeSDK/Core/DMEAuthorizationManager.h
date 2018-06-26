//
//  DMEAuthorizationManager.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEClientCallbacks.h"
#import "DMEMercuryInterfacer.h"

@interface DMEAuthorizationManager : NSObject <DMEMercuryInterfacee>


/**
 Initiates contract authorization launching Digi.me App if there is a valid active session.
 
 @param completion AuthorizationCompletionBlock
 */
- (void)beginAuthorizationWithCompletion:(AuthorizationCompletionBlock)completion;

@end
