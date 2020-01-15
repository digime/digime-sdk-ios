//
//  DMEAuthorityPublicKey.h
//  DigiMeSDK
//
//  Created on 14/01/2020.
//  Copyright © 2020 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMEAuthorityPublicKey : NSObject

@property (nonatomic, strong, readonly) NSString *publicKey;

/**
 -init unavailable. Use -initWithPublicKey:date:

 @return instancetype
 */
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;


/**
 Designated object initializer.

 @param publicKey public key in base 64 format
 @param date creation date
 @return instancetype.
 */
- (instancetype)initWithPublicKey:(NSString *)publicKey date:(NSDate *)date NS_DESIGNATED_INITIALIZER;

- (BOOL)isValid;

@end

NS_ASSUME_NONNULL_END
