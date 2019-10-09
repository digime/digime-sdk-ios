//
//  DMEFileListDeserializer.m
//  DigiMeSDK
//
//  Created on 13/08/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEFileListDeserializer.h"

@implementation DMEFileListDeserializer

+ (DMEFileList *)deserialize:(NSData *)jsonData error:(NSError * _Nullable __autoreleasing *)error
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:error];
    
    if (json)
    {
        return [[DMEFileList alloc] initWithJSON:json];
    }
    
    return nil;
}

@end
