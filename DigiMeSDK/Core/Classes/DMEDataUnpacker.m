//
//  DMEDataUnpacker.m
//  DigiMeSDK
//
//  Created on 04/12/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEDataDecryptor.h"
#import "DMECompressor.h"
#import "DMEDataUnpacker.h"
#import "NSError+SDK.h"
#import <DigiMeSDK/DigiMeSDK-Swift.h>

@implementation DMEDataUnpacker

+ (nullable NSData *)unpackData:(NSData *)data decryptor:(DMEDataDecryptor *)decryptor resolvedMetadata:(DMEFileMetadata * _Nullable __autoreleasing * _Nullable)resolvedMetadata error:(NSError * _Nullable __autoreleasing *)error
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:error];
    
    if (!json)
    {
        [NSError setSDKError:SDKErrorInvalidData toError:error];
        return nil;
    }
    
    NSDictionary *metadataJSON = json[@"fileMetadata"];
    if (metadataJSON && resolvedMetadata)
    {
        *resolvedMetadata = [DMEFileMetadata metadataFromJSON:metadataJSON];
    }
    
    id fileContent = json[@"fileContent"];
    if (!fileContent)
    {
        [NSError setSDKError:SDKErrorInvalidData toError:error];
        return nil;
    }
    
    NSData *unpackedData = [decryptor decryptFileContent:fileContent error:error];
    
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
    else if ([compression isEqualToString:@"gzip"])
    {
        unpackedData = [DMECompressor decompressData:unpackedData usingAlgorithm:DMECompressionAlgorithmGZIP];
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
