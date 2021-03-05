//
//  DMEOAuthToken.m
//  DigiMeSDK
//
//  Created on 12/12/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEOAuthToken.h"

@implementation DMEOAuthToken

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.accessToken forKey:@"accessToken"];
    [encoder encodeObject:self.expiresOn forKey:@"expiresOn"];
    [encoder encodeObject:self.refreshToken forKey:@"refreshToken"];
    [encoder encodeObject:self.tokenType forKey:@"tokenType"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init]))
    {
        self.accessToken = [decoder decodeObjectOfClass:[NSString class] forKey:@"accessToken"];
        self.expiresOn = [decoder decodeObjectOfClass:[NSDate class] forKey:@"expiresOn"];
        self.refreshToken = [decoder decodeObjectOfClass:[NSString class] forKey:@"refreshToken"];
        self.tokenType = [decoder decodeObjectOfClass:[NSString class] forKey:@"tokenType"];
    }
    
    return self;
}

@end
