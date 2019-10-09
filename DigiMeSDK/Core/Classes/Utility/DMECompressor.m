//
//  DMECompressor.m
//  DigiMeSDK
//
//  Created on 21/11/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMECompressor.h"
@import GZIP;

@implementation DMECompressor

+ (nullable NSData *)compressData:(NSData *)data usingAlgorithm:(DMECompressionAlgorithm)algorithm
{
    switch (algorithm)
    {
        case DMECompressionAlgorithmGZIP:
            return [self gzipCompressData:data];
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
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Algorithm type %@ doesn't exist.", @(algorithm)];
    }
}

+ (nullable NSData *)gzipCompressData:(NSData *)data
{
    return [data gzippedData];
}

+ (nullable NSData *)gzipDecompressData:(NSData *)data
{
    return [data gunzippedData];
}

@end
