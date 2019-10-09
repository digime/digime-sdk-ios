//
//  DMEPushClient.m
//  DigiMeSDK
//
//  Created on 01/08/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEAPIClient+Postbox.h"
#import "DMEClient+Private.h"
#import "DMEPostboxConsentManager.h"
#import "DMEPushClient.h"
#import "DMEPushConfiguration.h"
#import "DMESessionManager.h"

@interface DMEPushClient ()

@property (nonatomic, strong) DMEPostboxConsentManager *postboxManager;

@end

@implementation DMEPushClient

- (instancetype)initWithConfiguration:(DMEPushConfiguration *)configuration
{
    self = [super initWithConfiguration:configuration];
    if (self)
    {
        _postboxManager = [[DMEPostboxConsentManager alloc] initWithSessionManager:self.sessionManager appId:self.configuration.appId];
    }
    
    return self;
}

- (void)openDMEAppForPostboxImport
{
    if ([self.appCommunicator canOpenDMEApp])
    {
        DMEOpenAction *action = @"postbox/import";
        [self.appCommunicator openDigiMeAppWithAction:action parameters:@{}];
    }
}

- (void)createPostboxWithCompletion:(DMEPostboxCreationCompletion)completion
{
    // Validation
    NSError *validationError = [self validateClient];
    if (validationError != nil)
    {
        completion(nil, validationError);
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    [self.sessionManager sessionWithScope:nil completion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!session)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            
            return;
        }
        
        [strongSelf.postboxManager requestPostboxWithCompletion:^(DMEPostbox * _Nullable postbox, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(postbox, error);
            });
        }];
    }];
}

- (void)pushDataToPostbox:(DMEPostbox *)postbox
                 metadata:(NSData *)metadata
                     data:(NSData *)data
               completion:(DMEPostboxDataPushCompletion)completion
{
    [self.apiClient pushDataToPostbox:postbox metadata:metadata data:data completion:^(NSError * _Nullable error) {
        completion(error);
    }];
}

@end

