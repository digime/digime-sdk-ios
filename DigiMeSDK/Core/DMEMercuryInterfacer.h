//
//  DMEMercuryInterfacer.h
//  DigiMeSDK
//
//  Created by Jacob King on 25/06/2018.
//  Copyright © 2018 me.digi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString DMEDigiMeOpenAction;

@protocol DMEMercuryInterfacee;

@interface DMEMercuryInterfacer : NSObject

- (BOOL)canOpenDigiMeApp;
- (void)openDigiMeAppWithAction:(DMEDigiMeOpenAction *)action parameters:(NSDictionary *)parameters;

- (void)addInterfacee:(id<DMEMercuryInterfacee>)interfacee;
- (void)removeInterfacee:(id<DMEMercuryInterfacee>)interfacee;

- (BOOL)openURL:(NSURL *)url options:(NSDictionary *)options;

@end

// Not a typo.
@protocol DMEMercuryInterfacee <NSObject>

@property (weak, nonatomic) DMEMercuryInterfacer *interfacer;

- (BOOL)canHandleAction:(DMEDigiMeOpenAction *)action;
- (void)handleAction:(DMEDigiMeOpenAction *)action withParameters:(NSDictionary<NSString *, id> *)parameters;

- (instancetype)initWithInterfacer:(DMEMercuryInterfacer __weak *)interfacer;

@end
