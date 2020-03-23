//
//  ViewController.m
//  DigiMeSDKExample
//
//  Created on 24/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "ViewController.h"
#import "LogViewController.h"
#import <DigiMeSDK/NSData+DMECrypto.h>
#import <DigiMeSDK/NSString+DMECrypto.h>

@import DigiMeSDK;

@interface ViewController ()

@property (nonatomic, strong) DMEPullClient *dmeClient;
@property (nonatomic, strong) LogViewController *logVC;
@property (nonatomic, strong) DMEPullConfiguration *configuration;
@property (nonatomic, strong) DMEOAuthToken *oAuthToken;

@end

@implementation ViewController

- (DMEPullConfiguration *)createSampleConfiguration
{
    // production
    NSString *appId = @"IfnN9Y27Jym3P1Fad3ks3sTlo22flUBb";
    NSString *contractId = @"r9ZPFD0bUqycDw6qPSg7AyGT7xisR8jM";
    DMEPullConfiguration *configuration = [[DMEPullConfiguration alloc] initWithAppId:appId contractId:contractId p12FileName:@"fJI8P5Z4cIhP3HawlXVvxWBrbyj5QkTF" p12Password:@"monkey periscope"];
    configuration.debugLogEnabled = YES;
    return configuration;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"CA Example";
    self.logVC = [LogViewController new];
    [self addChildViewController:self.logVC];
    self.logVC.view.frame = self.view.frame;
    [self.view addSubview:self.logVC.view];
    [self.logVC didMoveToParentViewController:self];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(startTapped:)];
    
    [self.logVC logMessage:@"Please press 'Start' to begin requesting data. Also make sure that digi.me app is installed and onboarded."];
    
    self.navigationController.toolbarHidden = NO;
    NSArray *barButtonItems = @[
                                [[UIBarButtonItem alloc] initWithTitle:@"➖" style:UIBarButtonItemStylePlain target:self action:@selector(zoomOut)],
                                [[UIBarButtonItem alloc] initWithTitle:@"➕" style:UIBarButtonItemStylePlain target:self action:@selector(zoomIn)]
                                ];

    self.toolbarItems = barButtonItems;
    
//    NSData *tokenData = [[NSUserDefaults standardUserDefaults] objectForKey:@"oauth_token"];
//
//    if (tokenData)
//    {
//        self.oAuthToken = [NSKeyedUnarchiver unarchiveObjectWithData:tokenData];
//    }
}

- (void)zoomIn
{
    [self.logVC increaseFontSize];
}
- (void)zoomOut
{
    [self.logVC decreaseFontSize];
}

- (IBAction)startTapped:(id)sender
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"digi.me" message:@"Choose Consent Access flow" preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Ongoing Consent Access" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self runOngoingAccessFlow];
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Legacy Consent Access" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self runLegacyFlow];
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];

    [self.navigationController presentViewController:actionSheet animated:YES completion:nil];
}

-  (void)runOngoingAccessFlow
{
    if (self.oAuthToken && [[NSDate date] compare: self.oAuthToken.expiresOn] == NSOrderedAscending)
    {
        [self resumeOngoingAccess];
    }
    else
    {
        [self beginOngoingAccess];
    }
}

- (void)beginOngoingAccess
{
    [self resetClient];
    [self updateNavigationBarWithMessage:@"Beginning Ongoing Access"];
    __weak __typeof(self)weakSelf = self;
    [self.dmeClient authorizeOngoingAccessWithScope:nil oAuthToken:nil completion:^(DMESession * _Nullable session, DMEOAuthToken * _Nullable oAuthToken, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (session == nil)
            {
                [strongSelf.logVC logMessage:[NSString stringWithFormat:@"Authorization failed: %@", error.localizedDescription]];
                [self clearNavigationBar];
                return;
            };
            
            [strongSelf.logVC logMessage:[NSString stringWithFormat:@"Authorization Succeeded for session: %@", session.sessionKey]];
            [strongSelf.logVC logMessage:[NSString stringWithFormat:@"OAuth access token: %@", oAuthToken.accessToken]];
            [strongSelf.logVC logMessage:[NSString stringWithFormat:@"OAuth refresh token: %@", oAuthToken.refreshToken]];
            [strongSelf.logVC logMessage:[NSString stringWithFormat:@"OAuth expiration date: %@", oAuthToken.expiresOn]];
            
            strongSelf.oAuthToken = oAuthToken;
            
//            NSData *tokenData = [NSKeyedArchiver archivedDataWithRootObject:oAuthToken];
//            [[NSUserDefaults standardUserDefaults] setObject:tokenData forKey:@"oauth_token"];

            //Uncomment relevant method depending on which you wish to receive.
            [strongSelf getAccounts];
            [strongSelf getSessionData];
            // [strongSelf getSessionFileList];
        });
    }];
}

- (void)resetClient
{
    self.configuration = [self createSampleConfiguration];
    
    if (self.configuration)
    {
        self.dmeClient = nil;
        self.dmeClient = [[DMEPullClient alloc] initWithConfiguration:self.configuration];
    }
}

- (void)runLegacyFlow
{
    [self resetClient];
    [self updateNavigationBarWithMessage:@"Beginning Legacy Flow"];
     __weak __typeof(self)weakSelf = self;
    [self.dmeClient authorizeWithCompletion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (session == nil)
        {
            [strongSelf.logVC logMessage:[NSString stringWithFormat:@"Authorization failed: %@", error.localizedDescription]];
            return;
        };
        
        [strongSelf.logVC logMessage:[NSString stringWithFormat:@"Authorization Succeeded for session: %@", session.sessionKey]];

        //Uncomment relevant method depending on which you wish to receive.
        [strongSelf getSessionData];
        // [strongSelf getSessionFileList];
        [strongSelf getAccounts];
    }];
}

- (void)getAccounts
{
    [self updateNavigationBarWithMessage:@"Retrieving Accounts Data"];
     __weak __typeof(self)weakSelf = self;
    [self.dmeClient getSessionAccountsWithCompletion:^(DMEAccounts * _Nullable accounts, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (accounts == nil)
        {
            [strongSelf.logVC logMessage:[NSString stringWithFormat:@"Failed to retrieve accounts: %@", error.localizedDescription]];
            strongSelf.oAuthToken = nil;
            return;
        };
        
        [strongSelf.logVC logMessage:[NSString stringWithFormat:@"Account Content: %@", accounts.json]];
    }];
}

- (void)updateNavigationBarWithMessage:(NSString *)message
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator startAnimating];
    self.title = message;
}

- (void)clearNavigationBar
{
    self.navigationItem.leftBarButtonItem = nil;
    self.title = @"CA Example";
}

- (void)getSessionFileList
{
    [self updateNavigationBarWithMessage:@"Retrieving Session File List"];
    __weak __typeof(self)weakSelf = self;
    [self.dmeClient getSessionFileListWithUpdateHandler:^(DMEFileList * fileList, NSArray *fileIds) {
         __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (fileIds.count > 0)
        {
            [strongSelf.logVC logMessage:[NSString stringWithFormat:@"\n\nNew files added or updated in the file List: %@, accounts: %@\n\n", fileIds, fileList.accounts]];
        }
        else
        {
            [strongSelf.logVC logMessage:[NSString stringWithFormat:@"\n\nFileList Status: %@, Accounts: %@", fileList.syncStateString, fileList.accounts]];
        }
    } completion:^(NSError * _Nullable error) {
         __strong __typeof(weakSelf)strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil)
            {
                [strongSelf.logVC logMessage:[NSString stringWithFormat:@"Client retrieve session file list failed: %@", error.localizedDescription]];
                strongSelf.oAuthToken = nil;
            }
            else
            {
                [strongSelf.logVC logMessage:@"-------------Finished fetching session FileList!-------------"];
            }
        
            [strongSelf clearNavigationBar];
        });
    }];
}

- (void)resumeOngoingAccess
{
    [self resetClient];
    [self updateNavigationBarWithMessage:@"Retrieving Ongoing Access File List"];
     __weak __typeof(self)weakSelf = self;
    [self.dmeClient authorizeOngoingAccessWithScope:nil oAuthToken:self.oAuthToken completion:^(DMESession * _Nullable session, DMEOAuthToken * _Nullable oAuthToken, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil)
            {
                [strongSelf.logVC logMessage:[NSString stringWithFormat:@"Retrieving Ongoing Access File List failed: %@", error.localizedDescription]];
                strongSelf.oAuthToken = nil;
            }
            else
            {
                [strongSelf.logVC logMessage:@"-------------Ongoing Access data triggered sucessfully-------------"];
                
                // if oAuthToken has expired, a new one will be returned
                strongSelf.oAuthToken = oAuthToken;
                
                //Uncomment relevant method depending on which you wish to receive.
                [strongSelf getAccounts];
                [strongSelf getSessionData];
                // [strongSelf getSessionFileList];
            }
        });
    }];
}

- (void)getSessionData
{
    [self updateNavigationBarWithMessage:@"Retrieving Session Data"];
    __weak __typeof(self)weakSelf = self;
    [self.dmeClient getSessionDataWithDownloadHandler:^(DMEFile * _Nullable file, NSError * _Nullable error) {
         __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (file != nil)
        {
            [strongSelf.logVC logMessage:[NSString stringWithFormat:@"Downloaded file: %@, record count: %@", file.fileId, @(file.fileContentAsJSON.count)]];
        }
        
        if (error != nil)
        {
            NSString *fileId = error.userInfo[kFileIdKey] ?: @"unknown";
            [strongSelf.logVC logMessage:[NSString stringWithFormat:@"Failed to retrieve content for fileId: < %@ > Error: %@", fileId, error.localizedDescription]];
        }
    } completion:^(DMEFileList * _Nullable fileList, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil)
            {
                [strongSelf.logVC logMessage:[NSString stringWithFormat:@"Client retrieve session data failed: %@", error.localizedDescription]];
            }
            else
            {
                [strongSelf.logVC logMessage:@"-------------Finished fetching session data!-------------"];
            }
        
            [strongSelf clearNavigationBar];
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
