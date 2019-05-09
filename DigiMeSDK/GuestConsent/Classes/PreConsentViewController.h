//
//  PreConsentViewController.h
//  DigiMeSDK
//
//  Created by digi.me Ltd. on 01/05/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PreConsentViewControllerDelegate <NSObject>

- (void)downloadDigimeFromAppstore;
- (void)authenticateUsingGuestConsent;

@end

@interface PreConsentViewController : UIViewController

@property (nonatomic, weak) id<PreConsentViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
