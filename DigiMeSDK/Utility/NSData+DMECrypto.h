//
//  NSData+DMECrypto.h
//  DigiMeSDK
//
//  Created on 25/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (DMECrypto)

/**
 Returns NSString as hex representation of NSData.

 @return hexString. Nil if NSData is empty
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
