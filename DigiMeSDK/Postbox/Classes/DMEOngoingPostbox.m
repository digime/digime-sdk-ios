//
//  DMEOngoingPostbox.m
//  DigiMeSDK
//
//  Created on 08/01/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

#import "DMEOAuthToken.h"
#import "DMEOngoingPostbox.h"

@implementation DMEOngoingPostbox

static NSString * const kSessionKeyCodingKey = @"kSessionKeyCodingKey";
static NSString * const kPostboxIdCodingKey = @"kPostboxIdCodingKey";
static NSString * const kOAuthTokenCodingKey = @"kOAuthTokenCodingKey";
static NSString * const kPublicKeyCodingKey = @"kPublicKeyCodingKey";

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.sessionKey forKey:kSessionKeyCodingKey];
    [encoder encodeObject:self.postboxId forKey:kPostboxIdCodingKey];
    [encoder encodeObject:self.oAuthToken forKey:kOAuthTokenCodingKey];
    [encoder encodeObject:self.postboxRSAPublicKey forKey:kPublicKeyCodingKey];
}

- (nullable instancetype)initWithCoder:(NSCoder *)decoder
{
    NSString *sessionKey = [decoder decodeObjectOfClass:[NSString class] forKey:kSessionKeyCodingKey];
    NSString *postboxId = [decoder decodeObjectOfClass:[NSString class] forKey:kPostboxIdCodingKey];
    DMEOAuthToken *oAuthToken = [decoder decodeObjectOfClass:[DMEOAuthToken class] forKey:kOAuthTokenCodingKey];
    
    if (sessionKey == nil || postboxId == nil || oAuthToken == nil)
    {
        return nil;
    }
    
    DMEOngoingPostbox *ongoingPostbox = [self initWithSessionKey:sessionKey postboxId:postboxId oAuthToken:oAuthToken];
    ongoingPostbox.postboxRSAPublicKey = [decoder decodeObjectOfClass:[NSString class] forKey:kPublicKeyCodingKey];
    
    return ongoingPostbox;
}

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
