//
//  DMEClient+Postbox.m
//  DigiMeSDK
//
//  Created on 16/10/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEClient+Postbox.h"
#import "DMEPostboxConsentManger.h"
#import "DMEClient+Private.h"
#import "DMESessionManager.h"
#import "DMEAPIClient.h"
#import "DMEAPIClient+Postbox.h"

@interface DMEClient ()

@property (nonatomic, weak) DMEPostboxConsentManger *postboxManager;

@end

@implementation DMEClient (Postbox)

#pragma mark - Begin ivar and accessor definitions.

DMEPostboxConsentManger *_postboxManager;

- (DMEPostboxConsentManger *)postboxManager
{
    return _postboxManager;
}

- (void)setPostboxManager:(DMEPostboxConsentManger *)postboxManager
{
    _postboxManager = postboxManager;
}

#pragma mark - End ivar and accessor definitions.

- (void)createPostboxWithCompletion:(DMEPostboxCreationCompletion)completion
{
    // Check if the manager has been instantiated.
    if (!self.postboxManager)
    {
        // Prepare manager.
        DMEPostboxConsentManger *pbxMgr = [[DMEPostboxConsentManger alloc] initWithAppCommunicator:self.appCommunicator];
        [self.appCommunicator addCallbackHandler:pbxMgr];
        self.postboxManager = pbxMgr;
    }
    
    //get session
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
