//
//  CAFileObject.m
//  DigiMeSDK
//
//  Created on 31/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "CAFileObject.h"

@implementation CAFileObject

#pragma mark - Initialization

-(instancetype)initWithJson:(NSDictionary *)json
{
    self = [super init];
    if (self)
    {
        _annotation                 = json[@"annotation"];
        _baseId                     = json[@"baseid"];
        _commentCount               = [json[@"commentcount"] integerValue];
        _createdDate                = json[@"createddate"];
        _entityId                   = json[@"entityid"];
        _favouriteCount             = [json[@"favouritecount"] integerValue];
        _isCommentable              = [json[@"iscommentable"] boolValue];
        _isFavourited               = [json[@"isfavourited"] boolValue];
        _isLikeable                 = [json[@"islikeable"] boolValue];
        _isLikes                    = [json[@"islikes"] boolValue];
        _isShared                   = [json[@"isshared"] boolValue];
        _isTruncated                = [json[@"istruncated"] boolValue];
        _latitude                   = [json[@"latitude"] floatValue];
        _likeCount                  = [json[@"likecount"] integerValue];
        _longitude                  = [json[@"longitude"] floatValue];
        _originalPostId             = json[@"originalpostid"];
        _originalCrossPostId        = json[@"originalcrosspostid"];
        _originalPostUrl            = json[@"originalposturl"];
        _personEntityId             = json[@"personentityid"];
        _personFileRelativePath     = json[@"personfilerelativepath"];
        _personFileUrl              = json[@"personfileurl"];
        _personFullName             = json[@"personfullname"];
        _personUsername             = json[@"personusername"];
        _postEntityId               = json[@"postentityid"];
        _postId                     = json[@"postid"];
        _postReplyCount             = json[@"postreplycount"];
        _postUrl                    = json[@"posturl"];
        _rawText                    = json[@"rawtext"];
        _referenceEntityId          = json[@"referenceentityid"];
        _referenceEntityType        = [json[@"referenceentitytype"] intValue];
        _shareCount                 = [json[@"sharecount"] integerValue];
        _socialNetworkUserEntityId  = json[@"socialnetworkuserentityid"];
        _source                     = json[@"source"];
        _text                       = json[@"text"];
        _title                      = json[@"title"];
        _type                       = [json[@"type"] intValue];
        _updatedDate                = json[@"updateddate"];
        _visibility                 = json[@"visibiity"];
    }
    
    return self;
}

#pragma mark - Overrides

-(NSString *)description
{
    NSString *description = @"";
    
    if (self.entityId.length > 0)
    {
        description = [NSString stringWithFormat:@"%@entityId: %@,\n", description, self.entityId];
    }
    
    if (self.title.length > 0)
    {
        description = [NSString stringWithFormat:@"%@title: %@,\n", description, self.title];
    }
    
    if (self.text.length > 0)
    {
        description = [NSString stringWithFormat:@"%@text: %@,\n", description, self.text];
    }
    
    if (self.createdDate)
    {
        description = [NSString stringWithFormat:@"%@createdDate: %@,\n", description, self.createdDate];
    }
    
    return [NSString stringWithFormat:@"\n<%@: %p,\n%@>",
            NSStringFromClass([self class]), self, description];
}

@end
