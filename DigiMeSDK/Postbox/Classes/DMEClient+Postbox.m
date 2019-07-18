//
//  DMEClient+Postbox.m
//  DigiMeSDK
//
//  Created on 16/10/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "DMEClient+Postbox.h"
#import "DMEPostboxManager.h"
#import "DMEClient+Private.h"
#import "DMESessionManager.h"
#import "DMEAPIClient.h"
#import "DMEAPIClient+Postbox.h"

@interface DMEClient ()

@property (nonatomic, weak) DMEPostboxManager *postboxManager;

@end

@implementation DMEClient (Postbox)

#pragma mark - Begin ivar and accessor definitions.

DMEPostboxManager* _postboxManager;

- (DMEPostboxManager *)postboxManager
{
    return _postboxManager;
}

- (void)setPostboxManager:(DMEPostboxManager *)postboxManager
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
        DMEPostboxManager *pbxMgr = [[DMEPostboxManager alloc] initWithAppCommunicator:self.appCommunicator];
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
                if (completion)
                {
                    completion(nil, error);
                    return;
                }
            });
            
            return;
        }
        
        [strongSelf.postboxManager requestPostboxWithCompletion:^(DMEPostbox * _Nullable postbox, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion)
                {
                    completion(postbox, error);
                    return;
                }
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
