//
//  DMEPullConfiguration.h
//  DigiMeSDK
//
//  Created on 08/08/2019
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEBaseConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Configuration object used by `DMEPullClient`.
 */
@interface DMEPullConfiguration : DMEBaseConfiguration

/**
 Your rsa public key hex. 
 */
@property (nonatomic, copy, nullable) NSString *publicKeyHex;

/**
 Enables one-time sharing in the authorization flow. Defaults to YES.
 */
@property (nonatomic) BOOL guestEnabled;

/**
 Determines interval between fileList fetches when using `getSessionData` or `getSessionFileList`.
 Defaults to 3 seconds.
 */
@property (nonatomic) NSTimeInterval pollInterval;

/**
 Determines max number of retries before `getSessionData` or `getSessionFileList` times out.
 Time out condition is reached when there have been no updates to the `DMEFileList` during specified number of polls.
 Defaults to 100. This is affected by `pollInterval`. Using default values these would result in 100 * 3 = 300 seconds (5 minutes).
 */
@property (nonatomic) NSInteger maxStalePolls;

@end

NS_ASSUME_NONNULL_END
