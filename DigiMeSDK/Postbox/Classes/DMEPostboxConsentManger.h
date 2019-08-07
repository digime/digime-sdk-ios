//
//  DMEPostboxConsentManger.h
//  DigiMeSDK
//
//  Created on 26/06/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEAppCommunicator+Private.h"
#import "DMEClientCallbacks.h"

NS_ASSUME_NONNULL_BEGIN

@class DMESessionManager;

@interface DMEPostboxConsentManger : NSObject <DMEAppCallbackHandler>

- (instancetype)initWithSessionManager:(DMESessionManager *)sessionManager appId:(NSString *)appId NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)requestPostboxWithCompletion:(DMEPostboxCreationCompletion)completion;

@end

NS_ASSUME_NONNULL_END
