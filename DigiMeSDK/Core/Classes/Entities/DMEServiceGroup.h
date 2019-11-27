//
//  DMEServiceGroup.h
//  DigiMeSDK
//
//  Created on 21/11/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEServiceType.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMEServiceGroup: NSObject

/**
 ServiceGroup is a high level JFS object definition.  e.g.`1` for Social, `2` for Medical etc.
 
  - seealso:
 For more information, see [digi.me Developer Portal]
 (https://developers.digi.me/reference-objects#service-group)
 
 ### Useful links
 * [digi.me Developer Portal]
*/
@property (nonatomic, readonly) NSUInteger serviceGroupId;

/**
 ServiceType is a JFS ServiceGroup subcategory object definition.  e.g. `1` for Facebook, `3` for Twitter etc.

   - seealso:
  For more information, see [digi.me Developer Portal]
 (https://developers.digi.me/reference-objects#services)
 
 ### Useful links
 * [digi.me Developer Portal]
*/
@property (nonatomic, strong, readonly) NSArray<DMEServiceType *> *serviceTypes;

/**
-init unavailable. Use -initWithServiceGroup:serviceTypes:

@return instancetype
*/
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 Designated object initializer.

@param serviceGroupId NSUInteger Object identifier that is a representation of the JFS ServiceGroup entity. ServiceGroup is a top level category, such us Social, Finance etc.
@param serviceTypes NSArray ServiceType is a representation of the ServiceGroup subcategory in the JFS supported objects hierarchy. Such us Facebook, Twitter etc.
@return instancetype.
*/
- (instancetype)initWithServiceGroup:(NSUInteger)serviceGroupId serviceTypes:(NSArray<DMEServiceType *> *)serviceTypes NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
