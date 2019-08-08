//
//  DMEDataDecryptor.m
//  DigiMeSDK
//
//  Created on 05/02/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMECrypto.h"
#import "DMEDataDecryptor.h"
#import "DMEPullConfiguration.h"
#import "NSError+SDK.h"
#import "NSString+DMECrypto.h"

@interface DMEDataDecryptor ()

@property (nonatomic, strong, readonly) DMEPullConfiguration *configuration;

@end

@implementation DMEDataDecryptor

- (instancetype)initWithConfiguration:(DMEPullConfiguration *)configuration
{
    self = [super init];
    if (self)
    {
        _configuration = configuration;
    }
    
    return self;
}

- (NSData *)decryptFileContent:(id)fileContent error:(NSError * _Nullable __autoreleasing *)error
{
    if ([fileContent isKindOfClass:[NSString class]] && [fileContent length] && [fileContent isBase64])
    {
        NSData *encryptedData = [fileContent base64Data];
        NSData *decryptedData = [DMECrypto getDataFromEncryptedBytes:encryptedData
                                                          contractId:self.configuration.contractId
                                                       privateKeyHex:self.configuration.privateKeyHex];
        
        if (!decryptedData)
        {
            [NSError setSDKError:SDKErrorDecryptionFailed toError:error];
            return nil;
        }
        
        return decryptedData;
    }
    else if ([fileContent isKindOfClass:[NSDictionary class]] || [fileContent isKindOfClass:[NSArray class]])
    {
        NSError *serializationError;
        NSData *unencryptedData = [NSJSONSerialization dataWithJSONObject:fileContent options:kNilOptions error:&serializationError];
        
        if (!unencryptedData)
        {
            [NSError setSDKError:SDKErrorInvalidData toError:error];
            return nil;
        }
        
        return unencryptedData;
    }
    else if ([fileContent isKindOfClass:[NSString class]] && [fileContent length] > 0)
    {
        return [(NSString *)fileContent dataUsingEncoding:NSUTF8StringEncoding];
    }
    else if ([fileContent isKindOfClass:[NSData class]])
    {
        return (NSData *)fileContent;
    }
    
    [NSError setSDKError:SDKErrorInvalidData toError:error];
    return nil;
}

@end
