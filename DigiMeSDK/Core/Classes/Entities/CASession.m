//
//  CASession.m
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "CASession.h"
#import "CASessionManager.h"
#import "DMEClient.h"

@implementation CASession

#pragma mark - Initialization

-(instancetype)initWithSessionKey:(NSString *)sessionKey expiryDate:(NSDate *)expiryDate sessionManager:(CASessionManager *)sessionManager
{
    self = [super init];
    if (self)
    {
        _sessionKey = sessionKey;
        _expiryDate = expiryDate;
        _sessionManager = sessionManager;
        _sessionId = sessionManager.client.contractId;
        _createdDate = [NSDate date];
    }
    
    return self;
}

@end
