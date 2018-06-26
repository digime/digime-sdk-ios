//
//  CAFiles.m
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "CAFiles.h"

@implementation CAFiles

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
