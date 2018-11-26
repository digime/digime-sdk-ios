//
//  DMEQuarkManager.h
//  DigiMeSDK
//
//  Created on 22/11/2018.
//  Copyright © 2018 me.digi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEAppCommunicator.h"
#import "DMEClientCallbacks.h"

@interface DMEQuarkManager : NSObject <DMEAppCallbackHandler>

- (void)requestQuarkWithBaseUrl:(NSString *)baseUrl withCompletion:(AuthorizationCompletionBlock)completion;

@end
