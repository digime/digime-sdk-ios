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

@property (nonatomic, strong) DMEPullClient *dmeClient;
@property (nonatomic, strong) LogViewController *logVC;
@property (nonatomic, strong) DMEPullConfiguration *configuration;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // - GET STARTED -
    
    // - REPLACE 'YOUR_APP_ID' with your App ID. Also don't forget to set the app id in CFBundleURLSchemes.
    NSString *appId = @"YOUR_APP_ID";
    
    // - REPLACE 'YOUR_CONTRACT_ID' with your contract ID.
    NSString *contractId = @"YOUR_CONTRACT_ID";
    
    // - REPLACE 'YOUR_P12_FILE_NAME' with .p12 file name (without the .p12 extension) provided by digi.me Ltd.
    NSString *p12Filename = @"YOUR_P12_FILE_NAME";
    
    // - REPLACE 'YOUR_P12_PASSWORD' with password provided by digi.me Ltd.
    NSString *p12Password = @"YOUR_P12_PASSWORD";
    
    self.configuration = [[DMEPullConfiguration alloc] initWithAppId:appId contractId:contractId p12FileName:p12Filename p12Password:p12Password];
    self.configuration.debugLogEnabled = YES;
    
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
    if (self.configuration)
    {
        self.dmeClient = nil;
        self.dmeClient = [[DMEPullClient alloc] initWithConfiguration:self.configuration];
    }
    
    [self.logVC reset];

    [self.dmeClient authorizeWithCompletion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        
        NSString *digiMeVersion = self.dmeClient.metadata[kDMEDigiMeVersion];
        if (digiMeVersion != nil)
        {
            [self.logVC logMessage:[NSString stringWithFormat:@"digi.me App Version: %@", digiMeVersion]];
        }

        if (session == nil)
        {
            [self.logVC logMessage:[NSString stringWithFormat:@"Authorization failed: %@", error.localizedDescription]];
            return;
        };
        
        [self.logVC logMessage:[NSString stringWithFormat:@"Authorization Succeeded for session: %@", session.sessionKey]];

        //Uncomment relevant method depending on which you wish to recieve.
        [self getSessionData];
//        [self getSessionFileList];
        [self getAccounts];
    }];
}

- (void)getAccounts
{
    [self.dmeClient getSessionAccountsWithCompletion:^(DMEAccounts * _Nullable accounts, NSError * _Nullable error) {
        
        if (accounts == nil)
        {
            [self.logVC logMessage:[NSString stringWithFormat:@"Failed to retrieve accounts: %@", error.localizedDescription]];
            return;
        };
        
        [self.logVC logMessage:[NSString stringWithFormat:@"Account Content: %@", accounts.json]];
    }];
}

- (void)getSessionFileList
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator startAnimating];
    self.title = @"Session FileList";
    
    [self.dmeClient getSessionFileListWithUpdateHandler:^(DMEFileList * fileList, NSArray *fileIds) {
        
        if (fileIds.count > 0)
        {
            [self.logVC logMessage:[NSString stringWithFormat:@"\n\nNew files added or updated in the file List: %@, accounts: %@\n\n", fileIds, fileList.accounts]];
        }
        else
        {
            [self.logVC logMessage:[NSString stringWithFormat:@"\n\nFileList Status: %@, Accounts: %@", fileList.syncStateString, fileList.accounts]];
        }
    } completion:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil)
            {
                [self.logVC logMessage:[NSString stringWithFormat:@"Client retrieve session file list failed: %@", error.localizedDescription]];
            }
            else
            {
                [self.logVC logMessage:@"-------------Finished fetching session FileList!-------------"];
            }
        
            self.navigationItem.leftBarButtonItem = nil;
            self.title = nil;
        });
    }];
}

- (void)getSessionData
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator startAnimating];
    self.title = @"Session Data";
    
    [self.dmeClient getSessionDataWithDownloadHandler:^(DMEFile * _Nullable file, NSError * _Nullable error) {
        
        if (file != nil)
        {
            [self.logVC logMessage:[NSString stringWithFormat:@"Downloaded file: %@, record count: %@", file.fileId, @(file.fileContentAsJSON.count)]];
        }
        
        if (error != nil)
        {
            NSString *fileId = error.userInfo[kFileIdKey] ?: @"unknown";
            [self.logVC logMessage:[NSString stringWithFormat:@"Failed to retrieve content for fileId: < %@ > Error: %@", fileId, error.localizedDescription]];
        }
    } completion:^(DMEFileList * _Nullable fileList, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil)
            {
                [self.logVC logMessage:[NSString stringWithFormat:@"Client retrieve session data failed: %@", error.localizedDescription]];
            }
            else
            {
                [self.logVC logMessage:@"-------------Finished fetching session data!-------------"];
            }
        
            self.navigationItem.leftBarButtonItem = nil;
            self.title = nil;
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
