//
//  NSString+DMECrypto.h
//  DigiMeSDK
//
//  Created on 25/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (DMECrypto)

/**
 Hex to Bytes conversion

 @return NSData
 */
- (NSData *)hexToBytes;


/**
 Verifies if NSString is in base64 format

 @return BOOL
 */
- (BOOL)isBase64;


/**
 NSString to base64 NSData conversion

 @return NSData
 */
- (NSData *)base64Data;

@end

NS_ASSUME_NONNULL_END
