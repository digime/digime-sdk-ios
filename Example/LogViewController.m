//
//  LogViewController.m
//  DigiMeSDKExample
//
//  Created on 31/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

#import "LogViewController.h"

static const CGFloat kMALoggingViewDefaultFontSize = 10.f;
static const CGFloat kMALoggingViewMinFontSize = 2.f;
static const CGFloat kMALoggingViewMaxFontSize = 28.f;
static NSString * const kMALoggingViewDefaultFont = @"Courier-Bold";

@interface LogViewController ()

@property (nonatomic, strong) UITextView* textView;
@property (nonatomic) CGFloat currentFontSize;

@end

@implementation LogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.currentFontSize = kMALoggingViewDefaultFontSize;
    [self generateTextView];
    
}

- (void)increaseFontSize
{
    if (self.currentFontSize >= kMALoggingViewMaxFontSize)
    {
        return;
    }
    self.currentFontSize += 1;
    self.textView.font = [UIFont fontWithName:kMALoggingViewDefaultFont size:self.currentFontSize];
}

- (void)decreaseFontSize
{
    if (self.currentFontSize <= kMALoggingViewMinFontSize)
    {
        return;
    }
    self.currentFontSize -= 1;
    self.textView.font = [UIFont fontWithName:kMALoggingViewDefaultFont size:self.currentFontSize];
}

- (void)reset
{
    self.textView.text = nil;
}

- (void)generateTextView
{
    self.textView = [[UITextView alloc] initWithFrame:self.view.frame];
    self.textView.backgroundColor = [UIColor blackColor];
    self.textView.editable = NO;
    self.textView.font = [UIFont fontWithName:kMALoggingViewDefaultFont size:self.currentFontSize];
    self.textView.textColor = [UIColor whiteColor];
    [self.view addSubview:self.textView];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //Trailing
    NSLayoutConstraint *trailing =[NSLayoutConstraint
                                   constraintWithItem:self.textView
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeTrailing
                                   multiplier:1.f
                                   constant:0.f];
    
    //Leading
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:self.textView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.view
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.f
                                   constant:0.f];
    
    //Bottom
    NSLayoutConstraint *bottom =[NSLayoutConstraint
                                 constraintWithItem:self.textView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self.view
                                 attribute:NSLayoutAttributeBottom
                                 multiplier:1.f
                                 constant:-self.bottomLayoutGuide.length];
    
    //Top
    NSLayoutConstraint *top =[NSLayoutConstraint
                              constraintWithItem:self.textView
                              attribute:NSLayoutAttributeTop
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeTop
                              multiplier:1.f
                              constant:self.topLayoutGuide.length];
    
    [self.view addConstraints:@[top, bottom, leading, trailing]];
}

- (void)scrollToBottom
{
    NSRange bottom = NSMakeRange(self.textView.text.length -1, 1);
    [self.textView scrollRangeToVisible:bottom];
}

- (void)logMessage:(NSString *)text
{
    if (text.length == 0)
    {
        return;
    }
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    NSString *dateString = [formatter stringFromDate:now];
    NSString *prevText = self.textView.text;
    self.textView.text = [NSString stringWithFormat:@"%@\n%@%@", prevText, dateString, text];
    [self scrollToBottom];
}

@end
