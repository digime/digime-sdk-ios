//
//  NSString+DMECrypto.h
//  DigiMe
//
//  Created on 25/01/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DMECrypto)


/**
 Hex to Bytes conversion

 @return NSMutableData
 */
- (NSMutableData *)hexToBytes;


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
