//
//  DMEOngoingPostbox.m
//  DigiMeSDK
//
//  Created on 08/01/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

#import "DMEOngoingPostbox.h"

@implementation DMEOngoingPostbox

- (instancetype)initWithSessionKey:(NSString *)sessionKey postboxId:(NSString *)postboxId oAuthToken:(DMEOAuthToken *)oAuthToken
{
    self = [super initWithSessionKey:sessionKey andPostboxId:postboxId];
    if (self)
    {
        _oAuthToken = oAuthToken;
    }
    
    return self;
}

- (instancetype)initWithPostbox:(DMEPostbox *)postbox oAuthToken:(DMEOAuthToken *)oAuthToken
{
    DMEOngoingPostbox *ongoingPostbox = [self initWithSessionKey:postbox.sessionKey postboxId:postbox.postboxId oAuthToken:oAuthToken];
    ongoingPostbox.postboxRSAPublicKey = postbox.postboxRSAPublicKey;
    return ongoingPostbox;
}

- (DMEOngoingPostbox *)updatedPostboxWithSessionKey:(NSString *)sessionKey
{
    DMEOngoingPostbox *updatedPostbox = [[DMEOngoingPostbox alloc] initWithSessionKey:sessionKey postboxId:self.postboxId oAuthToken:self.oAuthToken];
    updatedPostbox.postboxRSAPublicKey = self.postboxRSAPublicKey;
    return updatedPostbox;
}

@end
