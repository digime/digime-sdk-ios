//
//  CAAccounts.h
//  DigiMeSDK
//
//  Created on 05/02/2018.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CAServiceDescriptor : NSObject

/**
 -init unavailable. Use -initWithName:logo:
 
 @return instancetype.
 */
- (instancetype)init NS_UNAVAILABLE;


/**
 Designated Initializer

 @param name serviceName
 @param logo service logo
 @return instancetype
 */
- (instancetype)initWithName:(NSString *)name logo:(nullable NSString *)logo NS_DESIGNATED_INITIALIZER;


/**
 Service name.
 */
@property (nonatomic, strong, readonly) NSString *name;


/**
 Service logo.
 */
@property (nullable, nonatomic, strong, readonly) NSString *logo;


@end

@interface CAAccount : NSObject

/**
 -init unavailable. Use -initWithId:name:number:service::
 
 @return instancetype.
 */
- (instancetype)init NS_UNAVAILABLE;


/**
 Designated object initializer

 @param identifier NSString
 @param name NSString
 @param number NSString
 @param service CAServiceDecriptor
 @return instancetype
 */
- (instancetype)initWithId:(nullable NSString *)identifier name:(nullable NSString *)name number:(nullable NSString *)number service:(nullable CAServiceDescriptor *)service NS_DESIGNATED_INITIALIZER;


/**
 Account identifier.
 */
@property (nullable, nonatomic, strong, readonly) NSString *identifier;


/**
 Account name.
 */
@property (nullable, nonatomic, strong, readonly) NSString *name;


/**
 Account number.
 */
@property (nullable, nonatomic, strong, readonly) NSString *number;


/**
 Account service descriptor.
 */
@property (nullable, nonatomic, strong, readonly) CAServiceDescriptor *service;

@end

@interface CAAccounts : NSObject

+ (nullable CAAccounts *)deserialize:(NSData *)data error:(NSError **)error;


/**
 -init unavailable. Use -initWithFileId:
 
 @return instancetype
 */
- (instancetype)init NS_UNAVAILABLE;


/**
 Designated object initializer.
 
 @param fileId NSString
 @param json NSDicitonary
 @return instancetype
 */
- (instancetype)initWithFileId:(NSString *)fileId json:(NSDictionary *)json NS_DESIGNATED_INITIALIZER;



/**
 File Identifier. This value is returned from the file list.
 */
@property (nonatomic, strong, readonly) NSString *fileId;


/**
 Serialized representation of the file's json.
 */
@property (nullable, nonatomic, strong, readonly) NSDictionary *json;


/**
 Array of CAAccount found in the account.
 */
@property (nullable, nonatomic, strong, readonly) NSArray<CAAccount *> *accounts;

@end

NS_ASSUME_NONNULL_END
