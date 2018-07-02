//
//  DMEPostboxManager.m
//  DigiMeSDK
//
//  Created by Jacob King on 26/06/2018.
//  Copyright © 2018 me.digi. All rights reserved.
//

#import "DMEPostboxManager.h"
#import "CASessionManager.h"
#import "DMEClient.h"

static NSString * const kCARequestSessionKey = @"CARequestSessionKey";
static NSString * const kCARequestPostboxId = @"CARequestPostboxId";
static NSString * const kCARequestPostboxPublicKey = @"kCARequestPostboxPublicKey";

@interface DMEPostboxManager()

@property (nonatomic, strong, readonly) CASession *session;
@property (nonatomic, strong, readonly) CASessionManager *sessionManager;
@property (nonatomic, copy, nullable) PostboxCreationCompletionBlock postboxCompletionBlock;

@end

@implementation DMEPostboxManager

#pragma mark - Interfacee Conformance

@synthesize interfacer = _interfacer;

- (instancetype)initWithInterfacer:(DMEMercuryInterfacer *__weak)interfacer
{
    self = [super init];
    if (self)
    {
        _interfacer = interfacer;
    }
    return self;
}

- (BOOL)canHandleAction:(DMEDigiMeOpenAction *)action
{
    return [action isEqualToString:@"postbox"];
}

- (void)handleAction:(DMEDigiMeOpenAction *)action withParameters:(NSDictionary<NSString *,id> *)parameters
{
    NSString *sessionKey = parameters[kCARequestSessionKey];
    NSString *postboxId = parameters[kCARequestPostboxId];
    NSString *postboxPublicKey = parameters[kCARequestPostboxPublicKey];
    
    NSError *err;
    CAPostbox *postbox;
    
    if(![self.sessionManager isSessionKeyValid:sessionKey])
    {
        err = [NSError authError:AuthErrorInvalidSessionKey];
    }
    else if(!postboxId.length)
    {
        err = [NSError authError:AuthErrorGeneral];
    }
    else
    {
        postbox = [[CAPostbox alloc] initWithSessionKey:sessionKey andPostboxId:postboxId];
        postbox.postboxSymmetricKey = postboxPublicKey;
    }
    
    if (self.postboxCompletionBlock)
    {
        // Need to know if we succeeded.
        dispatch_async(dispatch_get_main_queue(), ^{
            self.postboxCompletionBlock(postbox, err);
        });
    }
}

- (void)requestPostboxWithCompletion:(PostboxCreationCompletionBlock)completion
{
    if (![self.sessionManager isSessionValid])
    {
        completion(nil, nil);
        return;
    }
    
    self.postboxCompletionBlock = completion;
    
    DMEDigiMeOpenAction *action = @"postbox";
    NSDictionary *params = @{kCARequestSessionKey: self.session.sessionKey};
    
    [self.interfacer openDigiMeAppWithAction:action parameters:params];
}

#pragma mark - Convenience

- (CASession *)session
{
    return self.sessionManager.currentSession;
}

-(CASessionManager *)sessionManager
{
    return [DMEClient sharedClient].sessionManager;
}

@end
