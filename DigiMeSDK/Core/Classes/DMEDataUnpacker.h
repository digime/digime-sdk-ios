//
//  DMEDataUnpacker.h
//  DigiMeSDK
//
//  Created on 04/12/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DMEFileMetadata;

@interface DMEDataUnpacker : NSObject

/**
 Unpacks (i.e. decrypts and decompresses if necessary) the JSON data using private key.
 
 @param data The file's data
 @param resolvedMetadata The optional metadata which is populated upon unpacking
 @param error The optional error which is populated if unpacking fails
 @return Unpacked data if successful, otherwise nil
 */
+ (nullable NSData *)unpackData:(NSData *)data resolvedMetadata:(DMEFileMetadata * _Nullable __autoreleasing * _Nullable)resolvedMetadata error:(NSError * _Nullable __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
