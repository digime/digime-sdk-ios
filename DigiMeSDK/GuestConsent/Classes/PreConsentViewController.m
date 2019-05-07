//
//  PreConsentViewController.m
//  DigiMeSDK
//
//  Created by digi.me Ltd. on 01/05/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

#import "PreConsentViewController.h"
#import "PreConsentView.h"

static NSUInteger const kInset = 30;
static NSUInteger const kModalViewWidth = 290;
static NSUInteger const kModalViewHeight = 400;

@interface PreConsentViewController () <PreConsentViewDelegate>

@property (nonatomic, retain) PreConsentView *preConsentView;
@property (nonatomic, retain) UILabel *guestLabel;
@property (nonatomic, retain) UIVisualEffectView *blurEffectView;

@end

@implementation PreConsentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self buildUiAndRotate:NO];
}

- (void)buildUiAndRotate:(BOOL)rotate
{
    if (!UIAccessibilityIsReduceTransparencyEnabled())
    {
        self.view.backgroundColor = [UIColor clearColor];
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.blurEffectView.frame = self.view.bounds;
        self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if(!rotate)
        {
            [self.view addSubview:self.blurEffectView];
        }
    }
    else
    {
        self.view.backgroundColor = [UIColor blackColor];
    }
    
    if(rotate)
    {
        [self.guestLabel removeFromSuperview];
        [self.preConsentView removeFromSuperview];
    }
    
    CGRect viewFrame = CGRectMake((self.view.frame.size.width / 2) - (kModalViewWidth / 2), (self.view.frame.size.height / 2) - (kModalViewHeight / 2), kModalViewWidth, kModalViewHeight);
    self.preConsentView = [[PreConsentView alloc]initWithFrame:viewFrame];
    self.preConsentView.delegate = self;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"roundedCross" inBundle:bundle compatibleWithTraitCollection:nil];
    CGFloat imageOffsetY = attachment.image.size.height / 5;
    attachment.bounds = CGRectMake(0, -imageOffsetY, attachment.image.size.width, attachment.image.size.height);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
    [attributedString appendAttributedString:attachmentString];
    NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"  Not now, I’ll share as a guest", nil)];
    [attributedString appendAttributedString:textAfterIcon];
    
    self.guestLabel = [UILabel new];
    self.guestLabel.frame = CGRectMake(kInset, self.preConsentView.frame.origin.y + kModalViewHeight + kInset, self.view.frame.size.width - (kInset * 2), kInset);
    self.guestLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBlack];
    self.guestLabel.textColor = [UIColor whiteColor];
    self.guestLabel.numberOfLines = 0;
    self.guestLabel.textAlignment = NSTextAlignmentCenter;
    self.guestLabel.attributedText = attributedString;
    self.guestLabel.userInteractionEnabled = YES;
    self.guestLabel.adjustsFontSizeToFitWidth = YES;
    self.guestLabel.minimumScaleFactor = 0.5;
    [self.guestLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(guestConsentClicked)]];
    
    [self.view addSubview:self.guestLabel];
    [self.view addSubview:self.preConsentView];
}

- (void)appstoreButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(downloadDigimeFromAppstore)])
    {
        [self.delegate downloadDigimeFromAppstore];
    }
}

- (void)guestConsentClicked
{
    if ([self.delegate respondsToSelector:@selector(authenticateUsingGuestConsent)])
    {
        [self.delegate authenticateUsingGuestConsent];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         [self buildUiAndRotate:YES];
     } completion:nil];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

@end
