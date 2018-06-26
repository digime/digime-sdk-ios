//
//  CAPostbox.m
//  DigiMeSDK
//
//  Created by Jacob King on 25/06/2018.
//  Copyright © 2018 me.digi. All rights reserved.
//

#import "CAPostbox.h"

@implementation CAPostbox

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
