//
//  CAFileObject.h
//  DigiMeSDK
//
//  Created on 31/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CAFileObject : NSObject


/**
 -init unavailable. Use -initWithJson:

 @return instancetype.
 */
- (instancetype)init NS_UNAVAILABLE;


/**
 Designated object initializer.

 @param json NSDictionary of serialzed json.
 @return instancetype.
 */
- (instancetype)initWithJson:(NSDictionary *)json NS_DESIGNATED_INITIALIZER;


/**
 Returns serialized representation of object's JSON.
 */
@property (nullable, nonatomic, strong, readonly) NSDictionary *json;


/* --------------
 This section is experimental and subject to change.
 ----------------
 */
@property (nullable, nonatomic, strong, readonly) NSString *annotation;

@property (nullable, nonatomic, strong, readonly) NSString *baseId;

@property (nonatomic, readonly) NSInteger commentCount;

@property (nullable, nonatomic, strong, readonly) NSDate *createdDate;

@property (nullable, nonatomic, strong, readonly) NSString *entityId;

@property (nonatomic, readonly) NSInteger favouriteCount;

@property (nonatomic, readonly) BOOL isCommentable;

@property (nonatomic, readonly) BOOL isFavourited;

@property (nonatomic, readonly) BOOL isLikeable;

@property (nonatomic, readonly) BOOL isLikes;

@property (nonatomic, readonly) BOOL isShared;

@property (nonatomic, readonly) BOOL isTruncated;

@property (nonatomic, readonly) float latitude;

@property (nonatomic, readonly) float longitude;

@property (nonatomic, readonly) NSInteger likeCount;

@property (nullable, nonatomic, strong, readonly) NSString *originalCrossPostId;

@property (nullable, nonatomic, strong, readonly) NSString *originalPostUrl;

@property (nullable, nonatomic, strong, readonly) NSString *originalPostId;

@property (nullable, nonatomic, strong, readonly) NSString *personEntityId;

@property (nullable, nonatomic, strong, readonly) NSString *personFileRelativePath;

@property (nullable, nonatomic, strong, readonly) NSString *personFileUrl;

@property (nullable, nonatomic, strong, readonly) NSString *personFullName;

@property (nullable, nonatomic, strong, readonly) NSString *personUsername;

@property (nullable, nonatomic, strong, readonly) NSString *postEntityId;

@property (nullable, nonatomic, strong, readonly) NSString *postId;

@property (nullable, nonatomic, strong, readonly) NSString *postReplyCount;

@property (nullable, nonatomic, strong, readonly) NSString *postUrl;

@property (nullable, nonatomic, strong, readonly) NSString *rawText;

@property (nullable, nonatomic, strong, readonly) NSString *referenceEntityId;

@property (nonatomic, readonly) int referenceEntityType;

@property (nonatomic, readonly) NSInteger shareCount;

@property (nullable, nonatomic, strong, readonly) NSString *socialNetworkUserEntityId;

@property (nullable, nonatomic, strong, readonly) NSString *source;

@property (nullable, nonatomic, strong, readonly) NSString *text;

@property (nullable, nonatomic, strong, readonly) NSString *title;

@property (nonatomic, readonly) int type;

@property (nullable, nonatomic, strong, readonly) NSDate *updatedDate;

@property (nullable, nonatomic, strong, readonly) NSString *visibility;

NS_ASSUME_NONNULL_END

@end
