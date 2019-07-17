//
//  DMEFilesDeserializer.m
//  DigiMeSDK
//
//  Created on 30/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEFilesDeserializer.h"

@implementation DMEFilesDeserializer

+ (DMEFiles *)deserialize:(NSData *)jsonData error:(NSError * _Nullable __autoreleasing *)error
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:error];
    
    NSArray *fileList = (NSArray *)json[@"fileList"];
    
    if (fileList)
    {
        return [[DMEFiles alloc] initWithFileIds:fileList];
    }
    
    return nil;
}

@end
