//
//  CAFile.m
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "CAFile.h"

@implementation CAFile

#pragma mark - Deserialization
+ (CAFile *)deserialize:(NSData *)data fileId:(NSString *)fileId error:(NSError * _Nullable __autoreleasing *)error
{
    NSArray *content = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:error];
    
    CAFile *file = [[self alloc] initWithFileId:fileId];
    [file populateWithContent:content];
    return file;
}

#pragma mark - Initialization

-(instancetype)initWithFileId:(NSString *)fileId
{
    self = [super init];
    if (self)
    {
        _fileId = fileId;
    }
    
    return self;
}

#pragma mark - Public

- (void)populateWithContent:(NSArray *)content
{
    _json = content;
    
    NSMutableArray *objects = [NSMutableArray new];
    
    for (NSDictionary *obj in content)
    {
        CAFileObject *fileObject = [[CAFileObject alloc] initWithJson:obj];
        [objects addObject:fileObject];
    }
    
    _objects = objects;
}

#pragma mark - Overrides

-(NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"FileId: %@,\n", self.fileId];
    
    description = [NSString stringWithFormat:@"%@%i objects", description, (int)self.objects.count];
    
    return [NSString stringWithFormat:@"\n<%@: %p,\n%@>",
            NSStringFromClass([self class]), self, description];
}

@end
