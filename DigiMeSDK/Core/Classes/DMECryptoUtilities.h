//
//  DMECryptoUtilities.h
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Set of convenient cryptographical utility functions.
 */
@interface DMECryptoUtilities : NSObject

/**
 Extracts private key as hex string from p12File. This will return nil if an error occurs during extraction.

 @param p12FileName name of the p12 file in the bundle
 @param password password for the p12 file
 @return hex string representation of the private key
 */
+ (nullable NSString *)privateKeyHexFromP12File:(NSString *)p12FileName password:(NSString *)password;

/**
 Convenience method.
 Extracts private key as hex string from p12 file in NSData format. This will return nil if an error occurs during extraction.
 
 @param p12FileData bytes of the p12 file
 @param password password for the p12 file
 @return hex string representation of the private key
 */
+ (nullable NSString *)privateKeyHexFromP12Data:(NSData *)p12FileData password:(NSString *)password;

/**
 Convenience method.
 Extracts private key as hex string from p12File from a specific bundle. This will return nil if an error occurs during extraction.
 
 @param p12FileName name of the p12 file in the bundle
 @param password password for the p12 file
 @param bundle instance of NSBundle to extract p12 from
 @return hex string representation of the private key
 */
+ (nullable NSString *)privateKeyHexFromP12File:(NSString *)p12FileName password:(NSString *)password bundle:(NSBundle *)bundle;

/**
 Generates random data using length as a parameter.
 
 @param length int
 @return NSData - random bytes for the specified length.
 */
+ (NSData *)getRandomBytesWithLength:(int)length;

@end

NS_ASSUME_NONNULL_END
