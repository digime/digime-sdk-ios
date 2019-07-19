//
//  ViewController.m
//  DigiMeSDKExample
//
//  Created on 24/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "ViewController.h"
#import "LogViewController.h"

@import DigiMeSDK;

@interface ViewController ()

@property (nonatomic, strong) DMEClient *dmeClient;
@property (nonatomic) NSInteger fileCount;
@property (nonatomic) NSInteger progress;
@property (nonatomic, strong) LogViewController *logVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.dmeClient = [DMEClient sharedClient];
    
    // - GET STARTED -
    
    // - INSERT your App ID here -
    self.dmeClient.appId = @"YOUR_APP_ID";
    
    // - REPLACE 'YOUR_P12_PASSWORD' with password provided by digi.me Ltd
    self.dmeClient.privateKeyHex = [DMECryptoUtilities privateKeyHexFromP12File:@"fJI8P5Z4cIhP3HawlXVvxWBrbyj5QkTF" password:@"YOUR_P12_PASSWORD"];
    
    self.dmeClient.contractId = @"fJI8P5Z4cIhP3HawlXVvxWBrbyj5QkTF";
    
    self.fileCount = 0;
    self.progress = 0;
    
    self.logVC = [LogViewController new];
    [self addChildViewController:self.logVC];
    self.logVC.view.frame = self.view.frame;
    [self.view addSubview:self.logVC.view];
    [self.logVC didMoveToParentViewController:self];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(runTapped)];
    
    [self.logVC logMessage:@"Please press 'Start' to begin requesting data. Also make sure that digi.me app is installed and onboarded."];
    
    self.navigationController.toolbarHidden = NO;
    NSArray *barButtonItems = @[
                                [[UIBarButtonItem alloc] initWithTitle:@"➖" style:UIBarButtonItemStylePlain target:self action:@selector(zoomOut)],
                                [[UIBarButtonItem alloc] initWithTitle:@"➕" style:UIBarButtonItemStylePlain target:self action:@selector(zoomIn)]
                                ];

    self.toolbarItems = barButtonItems;
}

- (void)zoomIn
{
    [self.logVC increaseFontSize];
}
- (void)zoomOut
{
    [self.logVC decreaseFontSize];
}

- (void)runTapped
{
    self.progress = 0;
    [self.logVC reset];

    [self.dmeClient authorizeWithCompletion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        
        if (session == nil)
        {
            [self.logVC logMessage:[NSString stringWithFormat:@"Authorization failed: %@", error.localizedDescription]];
            return;
        };
        
        [self.logVC logMessage:[NSString stringWithFormat:@"Authorization Succeeded for session: %@", session.sessionKey]];

        [self getFileList];
        [self getAccounts];
    }];
}

- (void)getAccounts
{
    [self.dmeClient getAccountsWithCompletion:^(DMEAccounts * _Nullable accounts, NSError * _Nullable error) {
        
        if (accounts == nil)
        {
            [self.logVC logMessage:[NSString stringWithFormat:@"Failed to retrieve accounts: %@", error.localizedDescription]];
            return;
        };
        
        [self.logVC logMessage:[NSString stringWithFormat:@"Account Content: %@", accounts.json]];
        
    }];
}

- (void)getFileList
{
    [self.dmeClient getFileListWithCompletion:^(DMEFiles * _Nullable files, NSError * _Nullable error) {
        
        if (files == nil)
        {
            [self.logVC logMessage:[NSString stringWithFormat:@"Client retrieve fileList failed: %@", error.localizedDescription]];
            return;
        };
        
        self.fileCount = files.fileIds.count;
        
        for (NSString *fileId in files.fileIds)
        {
            [self getFileWith:fileId];
        }
        
    }];
}

- (void)getFileWith:(NSString *)Id
{
    [self.dmeClient getFileWithId:Id completion:^(DMEFile * _Nullable file, NSError * _Nullable error) {
        
        if (file == nil)
        {
            [self.logVC logMessage:[NSString stringWithFormat:@"Failed to retrieve content for fileId: < %@ > Error: %@", Id, error.localizedDescription]];
            return;
        };
        
        self.progress++;
        
        [self.logVC logMessage:[NSString stringWithFormat:@"File Content: %@", file.fileContentAsJSON]];
        [self. logVC logMessage:[NSString stringWithFormat:@"--------------------Progress: %i/%i", (int)self.progress, (int)self.fileCount]];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
