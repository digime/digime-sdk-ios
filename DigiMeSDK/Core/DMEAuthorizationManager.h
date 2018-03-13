//
//  DMEAuthorizationManager.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEClientCallbacks.h"

@interface DMEAuthorizationManager : NSObject


/**
 Initiates contract authorization launching Digi.me App if there is a valid active session.
 
 @param completion AuthorizationCompletionBlock
 */
- (void)beginAuthorizationWithCompletion:(AuthorizationCompletionBlock)completion;


/**
 Handles redirect back from Digi.me app.

 @param url NSURL
 @param options options
 @return YES if redirect could be handled, otherwise NO;
 */
- (BOOL)openURL:(NSURL *)url options:(NSDictionary *)options;

- (BOOL)canOpenDigiMeApp;

@end
