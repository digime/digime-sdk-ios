//
//  DMEOAuthObject.m
//  DigiMeSDK
//
//  Created on 12/12/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEOAuthObject.h"

@implementation DMEOAuthObject

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.accessToken forKey:@"accessToken"];
    [encoder encodeObject:self.expiresOn forKey:@"expiresOn"];
    [encoder encodeObject:self.refreshToken forKey:@"refreshToken"];
    [encoder encodeObject:self.tokenType forKey:@"tokenType"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if((self = [super init]))
    {
        self.accessToken = [decoder decodeObjectForKey:@"accessToken"];
        self.expiresOn = [decoder decodeObjectForKey:@"expiresOn"];
        self.refreshToken = [decoder decodeObjectForKey:@"refreshToken"];
        self.tokenType = [decoder decodeObjectForKey:@"tokenType"];
    }
    return self;
}

@end
