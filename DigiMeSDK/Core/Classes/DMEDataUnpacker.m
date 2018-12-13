//
//  DMEDataUnpacker.m
//  DigiMeSDK
//
//  Created on 04/121/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "CADataDecryptor.h"
#import "DMECompressor.h"
#import "DMEDataUnpacker.h"
#import "NSError+SDK.h"

@implementation DMEDataUnpacker

+ (nullable NSData *)unpackData:(NSData *)data error:(NSError * _Nullable __autoreleasing *)error
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:error];
    
    if (!json)
    {
        [NSError setSDKError:SDKErrorInvalidData toError:error];
        return nil;
    }
    
    id fileContent = json[@"fileContent"];
    if (!fileContent)
    {
        [NSError setSDKError:SDKErrorInvalidData toError:error];
        return nil;
    }
    
    NSData *unpackedData = [CADataDecryptor decryptFileContent:fileContent error:error];
    
    if (!unpackedData)
    {
        // Decryption failed - error already populated
        return nil;
    }
    
    NSString *compression = json[@"compression"];
    if ([compression isEqualToString:@"brotli"])
    {
        unpackedData = [DMECompressor decompressData:unpackedData usingAlgorithm:DMECompressionAlgorithmBrotli];
        if (!unpackedData)
        {
            // Decompression failed
            [NSError setSDKError:SDKErrorInvalidData toError:error];
            return nil;
        }
    }
    else if (compression != nil)
    {
        // Unknown compression. Return nil.
        [NSError setSDKError:SDKErrorInvalidData toError:error];
        return nil;
    }
    
    return unpackedData;
}

@end
