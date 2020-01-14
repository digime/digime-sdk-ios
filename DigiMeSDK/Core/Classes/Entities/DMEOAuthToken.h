//
//  DMEOAuthToken.h
//  DigiMeSDK
//
//  Created on 12/12/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMEOAuthToken : NSObject

// access token - gives access to protected resources via the digi.me Public API, without requiring users to disclose their digi.me credentials.
@property (nonatomic, copy, nullable) NSString *accessToken;

// access token expiration date
@property (nonatomic, copy, nullable) NSDate *expiresOn;

// refresh token - used as part of the process of obtaining a new access token.
@property (nonatomic, copy, nullable) NSString *refreshToken;

// token type - string describing access token type. Example - Bearer
@property (nonatomic, copy, nullable) NSString *tokenType;

@end

NS_ASSUME_NONNULL_END
