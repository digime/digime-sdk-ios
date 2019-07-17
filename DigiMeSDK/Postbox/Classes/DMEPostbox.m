//
//  DMEPostbox.m
//  DigiMeSDK
//
//  Created on 25/06/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEPostbox.h"

@implementation DMEPostbox

- (instancetype)initWithSessionKey:(NSString *)sessionKey andPostboxId:(NSString *)postboxId
{
    self = [super init];
    
    if (self)
    {
        _sessionKey = sessionKey;
        _postboxId = postboxId;
    }
    
    return self;
}

@end
