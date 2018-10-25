//
//  DMEPostboxManager.h
//  DigiMeSDK
//
//  Created on 26/06/2018.
//  Copyright © 2018 me.digi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEAppCommunicator.h"
#import "DMEClientCallbacks.h"

@interface DMEPostboxManager : NSObject <DMEAppCallbackHandler>

- (void)requestPostboxWithCompletion:(PostboxCreationCompletionBlock)completion;

@end
