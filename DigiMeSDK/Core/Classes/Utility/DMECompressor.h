//
//  DMECompressor.h
//  DigiMeSDK
//
//  Created on 21/11/2018.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DMECompressionAlgorithm) {
    DMECompressionAlgorithmGZIP, // Currently unused.
    DMECompressionAlgorithmBrotli,
};

@interface DMECompressor : NSObject

+ (nullable NSData *)compressData:(NSData *)data usingAlgorithm:(DMECompressionAlgorithm)algorithm;
+ (nullable NSData *)decompressData:(NSData *)data usingAlgorithm:(DMECompressionAlgorithm)algorithm;

@end

NS_ASSUME_NONNULL_END
