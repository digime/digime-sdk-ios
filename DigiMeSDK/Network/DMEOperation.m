//
//  DMEOperation.m
//  DigiMeSDK
//
//  Created on 26/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "DMEOperation.h"
#import <CoreGraphics/CoreGraphics.h>

@interface DMEOperation()
{
@protected
    
    BOOL _isExecuting;
    BOOL _isFinished;
    
    // if you need run loops (e.g. for libraries with delegate callbacks that require a run loop)
    BOOL _requiresRunLoop;
    NSTimer *_keepAliveTimer;  // a NSRunLoop needs a source input or timer for its run method to do anything.
    BOOL _stopRunLoop;
}

@property (nonatomic) NSInteger retryCount;
@property (nonatomic, strong) NSString *operationId;

@end

@implementation DMEOperation

#pragma mark - Lifecycle
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

-(instancetype)initWithConfiguration:(DMEClientConfiguration *)configuration
{
    self = [super init];
    if (self)
    {
        [self commonInit];
        _config = configuration;
    }
    return self;
}

- (void)commonInit
{
    _isExecuting = NO;
    _isFinished = NO;
    _retryCount = 0;
    _operationId = [[NSUUID UUID] UUIDString];
}

- (BOOL)isAsynchronous
{
    return YES;
}

- (BOOL)isExecuting
{
    return _isExecuting;
}

- (BOOL)isFinished
{
    return _isFinished;
}

- (void)start
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
    _isExecuting = YES;
    [self didChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
    
    _requiresRunLoop = YES;  // depends on your situation.
    if(_requiresRunLoop)
    {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        
        // run loops don't run if they don't have input sources or timers on them.  So we add a timer that we never intend to fire and remove him later.
        _keepAliveTimer = [NSTimer timerWithTimeInterval:CGFLOAT_MAX target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
        [runLoop addTimer:_keepAliveTimer forMode:NSDefaultRunLoopMode];
        
        [self doWork];
        
        NSTimeInterval updateInterval = 0.1f;
        NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:updateInterval];
        while (!_stopRunLoop && [runLoop runMode: NSDefaultRunLoopMode beforeDate:loopUntil])
        {
            loopUntil = [NSDate dateWithTimeIntervalSinceNow:updateInterval];
        }
    }
    else
    {
        [self doWork];
    }
}

- (void)timeout:(NSTimer*)timer
{
    // this method should never get called.
    
    [self finishDoingWork];
}

- (void)doWork
{
    if (self.config.debugLogEnabled)
    {
        NSLog(@"Executing operation: %@", self.operationId);
    }
    
    // do whatever stuff you need to do on a background thread.
    // Make network calls, asynchronous stuff, call other methods, etc.
    
    // and whenever the work is done, success or fail, whatever
    // be sure to call finishDoingWork.
    if (self.workBlock)
    {
        self.workBlock();
    }
    else
    {
        [self finishDoingWork];
    }
}

- (BOOL)canRetry
{
    return self.config.retryOnFail && self.retryCount < self.config.maxRetryCount;
}

- (BOOL)retry
{
    if (![self canRetry])
    {
        return NO;
    }
    
    self.retryCount++;
    double delay = (double)self.config.retryDelay; // ms
    
    if (self.config.debugLogEnabled)
    {
        NSLog(@"Retry Count: %i", (int)self.retryCount);
        NSLog(@"Retrying operation: %@, delay: %f", self.operationId, delay);
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_MSEC);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(popTime, queue, ^{
        [self doWork];
    });
    
    return YES;
}

- (void)finishDoingWork
{
    if (_requiresRunLoop)
    {
        // this removes (presumably still the only) timer from the NSRunLoop
        [_keepAliveTimer invalidate];
        _keepAliveTimer = nil;
        
        // and this will kill the while loop in the start method
        _stopRunLoop = YES;
    }
    
    [self finish];
    
}
- (void)finish
{
    // generate the KVO necessary for the queue to remove him
    [self willChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(isFinished))];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    [self didChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(isFinished))];
}

@end
