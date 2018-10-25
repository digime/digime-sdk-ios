//
//  DMEAppCommunicator.h
//  DigiMeSDK
//
//  Created on 25/06/2018.
//  Copyright © 2018 me.digi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString DMEOpenAction;

@protocol DMEAppCallbackHandler;

@interface DMEAppCommunicator : NSObject

- (BOOL)canOpenDigiMeApp;
- (void)openDigiMeAppWithAction:(DMEOpenAction *)action parameters:(NSDictionary *)parameters;

- (void)addCallbackHandler:(id<DMEAppCallbackHandler>)callbackHandler;
- (void)removeCallbackHandler:(id<DMEAppCallbackHandler>)callbackHandler;

- (BOOL)openURL:(NSURL *)url options:(NSDictionary *)options;

@end

// Not a typo.
@protocol DMEAppCallbackHandler <NSObject>

@property (weak, nonatomic) DMEAppCommunicator *appCommunicator;

- (BOOL)canHandleAction:(DMEOpenAction *)action;
- (void)handleAction:(DMEOpenAction *)action withParameters:(NSDictionary<NSString *, id> *)parameters;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAppCommunicator:(DMEAppCommunicator __weak *)appCommunicator;

@end
