//
//  DMEPreConsentViewController.h
//  DigiMeSDK
//
//  Created on 01/05/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DMEPreConsentViewControllerDelegate <NSObject>

- (void)downloadDigimeFromAppstore;
- (void)authenticateUsingGuestConsent;

@end

@interface DMEPreConsentViewController : UIViewController

@property (nonatomic, weak) id<DMEPreConsentViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
