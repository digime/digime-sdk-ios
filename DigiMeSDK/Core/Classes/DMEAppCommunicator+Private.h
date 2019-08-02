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

- (BOOL)canOpenDigiMeApp;
- (void)openDigiMeAppWithAction:(DMEOpenAction *)action parameters:(NSDictionary *)parameters;

- (void)addCallbackHandler:(id<DMEAppCallbackHandler>)callbackHandler;
- (void)removeCallbackHandler:(id<DMEAppCallbackHandler>)callbackHandler;

@end

@protocol DMEAppCallbackHandler <NSObject>

@property (weak, nonatomic) DMEAppCommunicator *appCommunicator;

- (BOOL)canHandleAction:(DMEOpenAction *)action;
- (void)handleAction:(DMEOpenAction *)action withParameters:(NSDictionary<NSString *, id> *)parameters;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAppCommunicator:(DMEAppCommunicator __weak *)appCommunicator;

@end

NS_ASSUME_NONNULL_END
