//
//  DMEAppCommunicator+Private.h
//  DigiMeSDK
//
//  Created on 02/08/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#pragma once
#import "DMEAppCommunicator.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString DMEOpenAction;

@protocol DMEAppCallbackHandler;

@interface DMEAppCommunicator (Private)

- (void)openDigiMeAppWithAction:(DMEOpenAction *)action parameters:(NSDictionary *)parameters;

- (void)addCallbackHandler:(id<DMEAppCallbackHandler>)callbackHandler;
- (void)removeCallbackHandler:(id<DMEAppCallbackHandler>)callbackHandler;

@end

@protocol DMEAppCallbackHandler <NSObject>

- (BOOL)canHandleAction:(DMEOpenAction *)action;
- (void)handleAction:(DMEOpenAction *)action withParameters:(NSDictionary<NSString *, id> *)parameters;

@end

NS_ASSUME_NONNULL_END
