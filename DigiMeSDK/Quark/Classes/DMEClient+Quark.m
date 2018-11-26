//
//  DMEClient+Quark.m
//  DigiMeSDK
//
//  Created on 22/11/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "DMEClient+Quark.h"
#import "DMEQuarkManager.h"
#import "DMEClient+Private.h"
#import "CASessionManager.h"
#import "DMEAPIClient.h"

@interface DMEClient ()

@property (nonatomic, weak) DMEQuarkManager *quarkManager;

@end

@implementation DMEClient (Quark)

@dynamic useGuestConsent;

DMEQuarkManager *_quarkManager;

-(DMEQuarkManager *)quarkManager
{
    return _quarkManager;
}

-(void)setQuarkManager:(DMEQuarkManager *)manager
{
    _quarkManager = manager;
}

- (void)createQuark
{
    [self createQuarkWithCompletion:nil];
}

- (void)createQuarkWithCompletion:(AuthorizationCompletionBlock)completion
{
    if (!self.quarkManager)
    {
        DMEQuarkManager *manager = [[DMEQuarkManager alloc] initWithAppCommunicator:self.appCommunicator];
        [self.appCommunicator addCallbackHandler:manager];
        self.quarkManager = manager;
    }
    
    __weak __typeof(self)weakSelf = self;
    [self.sessionManager sessionWithCompletion:^(CASession * _Nullable session, NSError * _Nullable error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!session)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion)
                {
                    completion(nil, error);
                }
                
                if ([strongSelf.delegate respondsToSelector:@selector(sessionCreateFailed:)])
                {
                    [strongSelf.delegate sessionCreateFailed:error];
                }
            });
            
            return;
        }
        
        [strongSelf.quarkManager requestQuarkWithBaseUrl:self.apiClient.baseUrl withCompletion:^(CASession * _Nullable session, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion)
                {
                    completion(session, error);
                }
                
                if (error)
                {
                    if ([strongSelf.delegate respondsToSelector:@selector(authorizeFailed:)])
                    {
                        [strongSelf.delegate authorizeFailed:error];
                    }
                }
                else if ([strongSelf.delegate respondsToSelector:@selector(authorizeSucceeded:)])
                {
                    [strongSelf.delegate authorizeSucceeded:session];
                }
            });
        }];
    }];
}

@end
