//
//  DMEOAuthObject.h
//  DigiMeSDK
//
//  Created on 12/12/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMEOAuthObject : NSObject

// access token - 1 day - medium-lived, token gives access to protected resources via the digi.me Public API, without requiring users to disclose their digi.me credentials to the consumers.
@property (nonatomic, strong, nullable) NSString *accessToken;
// access token expiration date
@property (nonatomic, strong, nullable) NSDate *expiresOn;
// refresh token - 30 days - long-lived, token must be used as part of the process of obtaining an access token.
@property (nonatomic, strong, nullable) NSString *refreshToken;
// token type - string describing access token type. Example - Bearer
@property (nonatomic, strong, nullable) NSString *tokenType;

@end

NS_ASSUME_NONNULL_END
