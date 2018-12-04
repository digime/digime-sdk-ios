//
//  CADataDecryptor.m
//  DigiMeSDK
//
//  Created on 05/02/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "CADataDecryptor.h"
#import "NSString+DMECrypto.h"
#import "DMECrypto.h"
#import "NSError+SDK.h"

@implementation CADataDecryptor

+ (NSData *)decryptFileContent:(id)fileContent error:(NSError * _Nullable __autoreleasing *)error
{
    if ([fileContent isKindOfClass:[NSString class]] && [fileContent length] && [fileContent isBase64])
    {
        DMECrypto *crypto = [DMECrypto new];
        NSData *encryptedData = [fileContent base64Data];
        NSData *privateKeyData = [crypto privateKeyHex];
        
        if (!privateKeyData)
        {
            [NSError setSDKError:SDKErrorNoPrivateKeyHex toError:error];
            return nil;
        }
        
        NSData *decryptedData = [crypto getDataFromEncryptedBytes:encryptedData privateKeyData:privateKeyData];
        
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
