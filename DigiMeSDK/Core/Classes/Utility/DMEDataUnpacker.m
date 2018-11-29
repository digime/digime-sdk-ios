//
//  DMEDataUnpacker.m
//  DigiMeSDK
//
//  Created by Jacob King on 28/11/2018.
//

#import "DMEDataUnpacker.h"
#import "DMECompressor.h"

@implementation DMEDataUnpacker

+ (nullable NSData *)unpackData:(NSData *)data fromRootData:(NSData *)rootData
{
    // Determine if data requires unpacking.
    // I.E. Has it been compressed?
    
    NSDictionary *jsonRepresentation = [NSJSONSerialization JSONObjectWithData:rootData options:kNilOptions error:NULL];
    
    NSString *compression = jsonRepresentation[@"compression"];
    
    if (!compression)
    {
        // No compression, return data as already unpacked.
        return data;
    }
    
    if ([compression isEqualToString:@"brotli"])
    {
        return [DMECompressor decompressData:data usingAlgorithm:DMECompressionAlgorithmBrotli];
    }
    
    // Unknown compression. Return nil.
    return nil;
}

@end
