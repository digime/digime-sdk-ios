//
//  DMEAuthorizationManager.m
//  CASDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "DMEAuthorizationManager.h"
#import "CASessionManager.h"
#import "DMEClient.h"
#import "NSError+Auth.h"
#import <UIKit/UIKit.h>

static NSString * const kCARequestSessionKey = @"CARequestSessionKey";
static NSString * const kCARequestRegisteredAppID = @"CARequestRegisteredAppID";
static NSString * const kCADigimeResponse = @"CADigimeResponse";
static NSString * const kDMEClientScheme = @"digime-ca-master";
static NSString * const kDMEClientSchemePrefix = @"digime-ca-";

@interface DMEAuthorizationManager()

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) CASession *session;
@property (nonatomic, strong) CASessionManager *sessionManager;
@property (nonatomic) BOOL authInProgress;
@property (nonatomic, copy, nullable) AuthorizationCompletionBlock authCompletionBlock;

@end

@implementation DMEAuthorizationManager

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _authInProgress = NO;
        _session = nil;
    }
    
    return self;
}

#pragma mark - Authorization

-(void)beginAuthorizationWithCompletion:(AuthorizationCompletionBlock)completion
{
    if (self.authInProgress)
    {
        NSError *authError = [NSError authError:AuthErrorInProgress];
        completion(self.session, authError);
        return;
    }
    
    if (![self.sessionManager isSessionValid])
    {
        completion(nil, [NSError authError:AuthErrorInvalidSession]);
        return;
    }
    
    self.authInProgress = YES;
    
    NSURLQueryItem*  sessionKeyComponent = [NSURLQueryItem queryItemWithName:kCARequestSessionKey value:self.session.sessionKey];
    NSURLQueryItem*  registereAppIdComponent = [NSURLQueryItem queryItemWithName:kCARequestRegisteredAppID value:self.appId];
    NSURLComponents* components = [NSURLComponents new];
    
    [components setQueryItems: @[sessionKeyComponent,registereAppIdComponent]];
    [components setScheme:kDMEClientScheme];
    [components setHost:@"data"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIApplication *app = [UIApplication sharedApplication];
        NSURL *url = components.URL;
        if ([app canOpenURL:url])
        {
            void (^completionBlock)(BOOL success) = ^void(BOOL success) {
                if(success)
                {
                    NSLog(@"[DMEClient] Authorization begun.");
                }
                else
                {
                    self.authCompletionBlock = nil;
                    completion(self.session, [NSError authError:AuthErrorGeneral]);
                    return;
                }
            };
            
            self.authCompletionBlock = completion;
            
            if (@available(iOS 10.0, *))
            {
                NSDictionary *options = @{UIApplicationOpenURLOptionUniversalLinksOnly : @NO};
                
                [app openURL:url options:options completionHandler:completionBlock];
            }
            else
            {
                //iOS 9 support
                BOOL success = [app openURL:url];
                completionBlock(success);
            }
        }
        else
        {
            completion(nil, [NSError authError:AuthErrorAppNotFound]);
        }
    });
}

#pragma mark - Digi.me App openURL handling

- (BOOL)openURL:(NSURL *)url options:(NSDictionary *)options
{
    //if we are not expecting a return, then skip logic.
    if (!self.authInProgress) { return NO; }
    
    BOOL canHandle = NO;
    if([url.absoluteString hasPrefix:kDMEClientSchemePrefix])
    {
        NSLog(@"[DMEClient] Digi.me callback intercepted.");
        
        canHandle = YES;
        NSURLComponents* urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        NSArray*         queryItems    = urlComponents.queryItems;
        
        BOOL result = [[self valueForKey:kCADigimeResponse inItems:queryItems] boolValue];
        NSString* sessionKey = [self valueForKey:kCARequestSessionKey inItems:queryItems];
        
        if(![self.sessionManager isSessionKeyValid:sessionKey])
        {
            [self executeCompletionWithSession:self.session error:[NSError authError:AuthErrorInvalidSessionKey]];
        }
        else if(result)
        {
            [self executeCompletionWithSession:self.session error:nil];
        }
        else
        {
            [self executeCompletionWithSession:self.session error:[NSError authError:AuthErrorCancelled]];
        }
        
        self.authInProgress = NO;
    }
    
    return canHandle;
}

#pragma mark - Private

- (void)executeCompletionWithSession:(CASession *)session error:(NSError *)error
{
    if (self.authCompletionBlock)
    {
        //all callbacks should be returned on main thread.
        if (![NSThread currentThread].isMainThread)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self executeCompletionWithSession:session error:error];
            });
            return;
        }
        
        self.authCompletionBlock(session, error);
        self.authCompletionBlock = nil;
    }
}

#pragma mark - Convenience

-(nullable NSString *)appId
{
    return [DMEClient sharedClient].appId;
}

- (CASession *)session
{
    return self.sessionManager.currentSession;
}

#pragma mark - Utilities
- (NSString *)valueForKey:(NSString *)key inItems:(NSArray *)queryItems
{
    NSPredicate*    predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
    NSURLQueryItem* queryItem = [[queryItems filteredArrayUsingPredicate:predicate] firstObject];
    return queryItem.value;
}

-(CASessionManager *)sessionManager
{
    return [DMEClient sharedClient].sessionManager;
}

@end
