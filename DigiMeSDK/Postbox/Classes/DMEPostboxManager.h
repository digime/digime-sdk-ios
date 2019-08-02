//
//  DMEPostboxManager.h
//  DigiMeSDK
//
//  Created on 26/06/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEAppCommunicator+Private.h"
#import "DMEClientCallbacks.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMEPostboxManager : NSObject <DMEAppCallbackHandler>

- (void)requestPostboxWithCompletion:(DMEPostboxCreationCompletion)completion;

@end

NS_ASSUME_NONNULL_END
