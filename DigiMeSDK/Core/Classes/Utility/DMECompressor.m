//
//  DMECompressor.m
//  DigiMeSDK
//
//  Created on 21/11/2018.
//

#import "DMECompressor.h"
@import Brotli;

@implementation DMECompressor

+ (nullable NSData *)compressData:(NSData *)data usingAlgorithm:(DMECompressionAlgorithm)algorithm
{
    switch (algorithm)
    {
        case DMECompressionAlgorithmGZIP:
            return [self gzipCompressData:data];
        case DMECompressionAlgorithmBrotli:
            return [self brotliCompressData:data];
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Algorithm type %@ doesn't exist.", @(algorithm)];
    }
}

+ (nullable NSData *)decompressData:(NSData *)data usingAlgorithm:(DMECompressionAlgorithm)algorithm
{
    switch (algorithm)
    {
        case DMECompressionAlgorithmGZIP:
            return [self gzipDecompressData:data];
        case DMECompressionAlgorithmBrotli:
            return [self brotliDecompressData:data];
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Algorithm type %@ doesn't exist.", @(algorithm)];
    }
}

+ (nullable NSData *)gzipCompressData:(NSData *)data
{
    [NSException raise:NSInternalInconsistencyException format:@"%@ is unimplemented.", NSStringFromSelector(_cmd)];
    return nil;
}

+ (nullable NSData *)gzipDecompressData:(NSData *)data
{
    [NSException raise:NSInternalInconsistencyException format:@"%@ is unimplemented.", NSStringFromSelector(_cmd)];
    return nil;
}

+ (nullable NSData *)brotliCompressData:(NSData *)data
{
    return [data brotliCompressed];
}

+ (nullable NSData *)brotliDecompressData:(NSData *)data
{
    return [data brotliDecompressed];
}

@end
