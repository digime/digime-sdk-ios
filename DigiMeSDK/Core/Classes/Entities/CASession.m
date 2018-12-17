//
//  CASession.m
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "CASession.h"
#import "CASessionManager.h"
#import "DMEClient.h"
#import "CADataRequest.h"

@implementation CASession

#pragma mark - Initialization

-(instancetype)initWithSessionKey:(NSString *)sessionKey expiryDate:(NSDate *)expiryDate sessionManager:(nonnull CASessionManager *)sessionManager
{
    self = [super init];
    if (self)
    {
        _sessionKey = sessionKey;
        _expiryDate = expiryDate;
        _sessionManager = sessionManager;
        _sessionId = sessionManager.client.contractId;
        _createdDate = [NSDate date];
        _scope = sessionManager.scope;
    }
    
    return self;
}

@end
