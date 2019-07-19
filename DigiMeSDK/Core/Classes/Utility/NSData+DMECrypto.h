//
//  NSData+DMECrypto.h
//  DigiMeSDK
//
//  Created on 25/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (DMECrypto)

/**
 Returns NSString as hex representation of NSData.

 @return hexString
 */
- (NSString *)hexString;


/**
 SHA256 NSString hash

 @return NSData
 */
- (NSData *)hashSha256;


/**
 SHA512 NSString hash.

 @return NSData
 */
- (NSData *)hashSha512;

@end

NS_ASSUME_NONNULL_END
