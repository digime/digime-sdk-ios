//
//  DMECryptoUtilities.h
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMECryptoUtilities : NSObject

/**
 Extracts private key as hex string from p12File. This will return nil if an error occurs during extraction.

 @param p12FileName name of the p12 file in the bundle
 @param password password for the p12 file
 @return hex string representation of the private key
 */
+ (nullable NSString *)privateKeyHexFromP12File:(NSString *)p12FileName password:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
