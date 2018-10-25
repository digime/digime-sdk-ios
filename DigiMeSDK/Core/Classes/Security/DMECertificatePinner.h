//
//  DMECertificatePinner.h
//  DigiMeSDK
//
//  Created on 25/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMECertificatePinner : NSObject


/**
 Perfomr certificate pinning. Please note this is turned off for debug builds.

 @param challenge NSURLAuthenticationChallenge
 @return NSURLSessionAuthChallengeDisposition
 */
- (NSURLSessionAuthChallengeDisposition)authenticateURLChallenge:(NSURLAuthenticationChallenge *)challenge;

NS_ASSUME_NONNULL_END

@end
