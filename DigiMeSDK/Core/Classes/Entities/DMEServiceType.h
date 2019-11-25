//
//  DMEServiceType.h
//  DigiMeSDK
//
//  Created on 21/11/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEServiceObjectType.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMEServiceType: NSObject <NSCoding, NSCopying> 

/**
 ServiceType is a subcategory of the JFS ServiceGroup object, such us Facebook, Twitter etc.
 
  - seealso:
 For more information, see [digi.me Developer Portal]
 (https://developers.digi.me/reference-objects#services)
 
 ### Useful links
 * [digi.me Developer Portal]
*/
@property (nonatomic, strong, readonly) NSNumber *serviceTypeId;

/**
 ObjectType is a JFS ServiceType subcategory object definition, such us social Comment, Media or a Post.

   - seealso:
  For more information, see [digi.me Developer Portal]
 (https://developers.digi.me/reference-objects#objects)
 
 ### Useful links
 * [digi.me Developer Portal]
*/
@property (nonatomic, strong, readonly, nullable) NSArray<DMEServiceObjectType *> *serviceObjectTypes;

/**
-init unavailable. Use -initWithServiceType:objectTypes:

@return instancetype
*/
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 Designated object initializer.

@param serviceTypeId NSNumber Object identifier that is a representation of the JFS ServiceType entity. ServiceType is a subcategory, such us Facebook, Twitter etc.
@param serviceObjectTypes NSArray optional parameter. ServiceObjectType is a representation of the ServiceType subcategory in the JFS objects hierarchy. Such us social Comment, Media or a Post.
@return instancetype.
*/
- (instancetype)initWithServiceType:(NSNumber *)serviceTypeId objectTypes:(NSArray <DMEServiceObjectType *> * _Nullable)serviceObjectTypes NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
