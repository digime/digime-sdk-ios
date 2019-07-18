//
//  DMEFiles.m
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEFiles.h"

@implementation DMEFiles

#pragma mark - Initialization

- (instancetype)initWithFileIds:(NSArray *)fileIds
{
    self = [super init];
    if (self)
    {
        _fileIds = fileIds;
    }
    
    return self;
}

@end
