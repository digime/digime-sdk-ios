//
//  CASession.h
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class CASessionManager;

@interface CASession : NSObject

/**
 -init unavailable. Use -initWithSessionKey:expiryDate:sessionManager:
 
 @return instancetype
 */
- (instancetype)init NS_UNAVAILABLE;


/**
 Designated object initializer.
 
 @param sessionKey NSString
 @param expiryDate NSDate
 @param sessionManager CASessionmanager
 @return instancetype
 */
- (instancetype)initWithSessionKey:(NSString *)sessionKey expiryDate:(NSDate *)expiryDate sessionManager:(CASessionManager *)sessionManager NS_DESIGNATED_INITIALIZER;


/**
 Session Key.
 */
@property (nonatomic, strong, readonly) NSString *sessionKey;


/**
 Date when session will expire.
 */
@property (nonatomic, strong, readonly) NSDate *expiryDate;


/**
 Session manager attached to the session.
 */
@property (nonatomic, strong, readonly) CASessionManager *sessionManager;


/**
 Date session was created.
 */
@property (nonatomic, strong, readonly) NSDate *createdDate;


/**
 Session Identifier - this is currently set to a contract identifier.
 */
@property (nonatomic, strong, readonly) NSString *sessionId;

@end

NS_ASSUME_NONNULL_END
