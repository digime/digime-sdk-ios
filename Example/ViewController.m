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
@property (nonatomic, strong) DMEOAuthObject *accessToken;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.logVC = [LogViewController new];
    [self addChildViewController:self.logVC];
    self.logVC.view.frame = self.view.frame;
    [self.view addSubview:self.logVC.view];
    [self.logVC didMoveToParentViewController:self];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(buttonClicked:)];
    
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

- (IBAction)buttonClicked:(id)sender
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
    if (self.accessToken && [[NSDate date] compare: self.accessToken.expiresOn] == NSOrderedAscending)
    {
        [self ongoingAccessRetrieveData];
    }
    else
    {
        [self beginOngoingAccess];
    }
}

- (void)beginOngoingAccess
{
    self.configuration = [self createSampleConfiguration];
    
    if (self.configuration)
    {
        self.dmeClient = nil;
        self.dmeClient = [[DMEPullClient alloc] initWithConfiguration:self.configuration];
    }
    
    [self.logVC reset];
    
    DMEScope *scope = [self createSampleScopeForOneYearOfSocialData];
    __weak __typeof(self)weakSelf = self;
    [self.dmeClient authorizeOngoingAccessWithScope:scope oAuthToken:nil completion:^(DMESession * _Nullable session, DMEOAuthObject * _Nullable accessToken, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (session == nil)
        {
            [self.logVC logMessage:[NSString stringWithFormat:@"Authorization failed: %@", error.localizedDescription]];
            return;
        };
        
        [self.logVC logMessage:[NSString stringWithFormat:@"Authorization Succeeded for session: %@", session.sessionKey]];
        [self.logVC logMessage:[NSString stringWithFormat:@"OAuth access token: %@", accessToken.accessToken]];
        [self.logVC logMessage:[NSString stringWithFormat:@"OAuth refresh token: %@", accessToken.refreshToken]];
        [self.logVC logMessage:[NSString stringWithFormat:@"OAuth expiration date: %@", accessToken.expiresOn]];
        
        strongSelf.accessToken = accessToken;
        
        //Uncomment relevant method depending on which you wish to recieve.
        [strongSelf getAccounts];
        [strongSelf getSessionData];
        // [strongSelf getSessionFileList];
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
    
    [self.logVC reset];

    [self.dmeClient authorizeWithCompletion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        
        if (session == nil)
        {
            [self.logVC logMessage:[NSString stringWithFormat:@"Authorization failed: %@", error.localizedDescription]];
            return;
        };
        
        [self.logVC logMessage:[NSString stringWithFormat:@"Authorization Succeeded for session: %@", session.sessionKey]];

        //Uncomment relevant method depending on which you wish to recieve.
        [self getSessionData];
        // [self getSessionFileList];
        [self getAccounts];
    }];
}

- (void)getAccounts
{
    [self updateNavigationBarWithMessage:@"Retrieving Accounts Data"];
    [self.dmeClient getSessionAccountsWithCompletion:^(DMEAccounts * _Nullable accounts, NSError * _Nullable error) {
        
        if (accounts == nil)
        {
            [self.logVC logMessage:[NSString stringWithFormat:@"Failed to retrieve accounts: %@", error.localizedDescription]];
            self.accessToken = nil;
            return;
        };
        
        [self.logVC logMessage:[NSString stringWithFormat:@"Account Content: %@", accounts.json]];
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
    self.title = nil;
}

- (void)getSessionFileList
{
    [self updateNavigationBarWithMessage:@"Retrieving Session File List"];
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
                self.accessToken = nil;
            }
            else
            {
                [self.logVC logMessage:@"-------------Finished fetching session FileList!-------------"];
            }
        
            [self clearNavigationBar];
        });
    }];
}

- (void)ongoingAccessRetrieveData
{
    [self resetClient];
    [self updateNavigationBarWithMessage:@"Retrieving Ongoing Access File List"];
    [self.dmeClient authorizeOngoingAccessWithScope:nil oAuthToken:self.accessToken completion:^(DMESession * _Nullable session, DMEOAuthObject * _Nullable accessToken, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil)
            {
                [self.logVC logMessage:[NSString stringWithFormat:@"Retrieving Ongoing Access File List failed: %@", error.localizedDescription]];
                self.accessToken = nil;
            }
            else
            {
                [self.logVC logMessage:@"-------------Ongoing Access data triggered sucessfully-------------"];
                
                // If old Access token has expired we get a new one. Here we store it locally for the next request.
                self.accessToken = accessToken;
                
                //Uncomment relevant method depending on which you wish to recieve.
                [self getAccounts];
                [self getSessionData];
                // [self getSessionFileList];
            }
        });
    }];
}

- (void)getSessionData
{
    [self updateNavigationBarWithMessage:@"Retrieving Session Data"];
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
        
            [self clearNavigationBar];
        });
    }];
}

- (DMEScope *)createSampleScopeForOneYearOfSocialData
{
    // An example to create a scope for one last year of social data.
    NSMutableArray *serviceObjectTypes = [NSMutableArray new];
    for (int i = 1; i <= 60; i++)
    {
        DMEServiceObjectType *serviceObjectType = [[DMEServiceObjectType alloc]initWithIdentifier:i];
        [serviceObjectTypes addObject:serviceObjectType];
    }
    
    DMEServiceType *serviceTypeFacebook = [[DMEServiceType alloc] initWithIdentifier:1 objectTypes: serviceObjectTypes];
    DMEServiceType *serviceTypeTwitter = [[DMEServiceType alloc] initWithIdentifier:3 objectTypes: serviceObjectTypes];
    DMEServiceType *serviceTypeInstagram = [[DMEServiceType alloc] initWithIdentifier:4 objectTypes: serviceObjectTypes];
    NSArray *serviceTypes = [NSArray arrayWithObjects: serviceTypeFacebook, serviceTypeTwitter, serviceTypeInstagram, nil];
    DMEServiceGroup *serviceGroupSocial = [[DMEServiceGroup alloc] initWithIdentifier:1 serviceTypes:serviceTypes];

    DMEScope *scope = [[DMEScope alloc] init];
    scope.serviceGroups = [NSArray arrayWithObjects: serviceGroupSocial, nil];
    
    NSDate *to = [NSDate date];
    NSUInteger componentFlags = NSCalendarUnitYear;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:componentFlags fromDate:to];
    [components setYear:-1];
    NSDate *from = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:to options:0];
    
    DMETimeRange *range = [DMETimeRange from:from to:to];
    scope.timeRanges = [NSArray arrayWithObjects:range, nil];
    return scope;
}

- (DMEPullConfiguration *)createSampleConfiguration
{
    NSString *appId = @"v8ddFfvvtLe0NSYI04BiysSvoeMGEyvD";
    NSString *contractId = @"2osfkdOLbFvJX3ylWHA6c0ZexxPfeCBh";
    NSString *publicKey = @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAgJG4g7MRRpFvA7FkVxDqLLd931WVR2yd5WDEgbOgQG0cyhyzRoOqvf27ombEG+R5jpAfJboQqO7+1/R+OAEsGcyoZUs89WbCnxy3q4Wb9kUMyr8Dgj0DjYcyeaSR75hQHD+QZo2YOMZxmp78quXERf8tP3FhCmpjDEPUendT7wk3LAuLpyz8nnVVp2X8V/HNBiHE0SJK3A6tZyDRO0GdxmqdEuBv/PNSs24OGQlfCsBAFksCXeEi83Pkz4CBhA3ihCouDHZUAFhhCngynVxKcBnET+HHqbEgsvw3gQEYjSpOH+wz0IAi0vVXqTFSdsp1+Tq+eQIl5bOwRovqyhXj4wIDAQAB";
    NSString *privateKey = @"MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCAkbiDsxFGkW8DsWRXEOost33fVZVHbJ3lYMSBs6BAbRzKHLNGg6q9/buiZsQb5HmOkB8luhCo7v7X9H44ASwZzKhlSzz1ZsKfHLerhZv2RQzKvwOCPQONhzJ5pJHvmFAcP5BmjZg4xnGanvyq5cRF/y0/cWEKamMMQ9R6d1PvCTcsC4unLPyedVWnZfxX8c0GIcTRIkrcDq1nINE7QZ3Gap0S4G/881Kzbg4ZCV8KwEAWSwJd4SLzc+TPgIGEDeKEKi4MdlQAWGEKeDKdXEpwGcRP4cepsSCy/DeBARiNKk4f7DPQgCLS9VepMVJ2ynX5Or55AiXls7BGi+rKFePjAgMBAAECggEAIH0yZE1u0ydTJ1q/YWUL2ArySuqEk4z2BY3Deocaus0X1lcUUoBZODOTI8HWUroUoZr30//Fz/q8+XN2Jc7eBxL5hsdRey3hhnWqUDSuKbhfOCi2yUWDzVLZxXV5z1LtA4ZohhHH4qj68ji03ra7N3j5RSvwesJRjzrgyaW31xJfW9a+TzYQZWONyxo8a7rY+9i/4k2BdNCvvWns7Fp47AZ1MzhUuVtXOQNsisEK5+jXXqJKA3iopcFFIGtD7Xzngwd8RIvQy7jZzRjkX28pkrrVAxvw6pqTXX889VhP7qS4g1TQ/baJ1aAZL5gFnu/WSuonBwE9CD0d/9aQr7YyIQKBgQDS70XlGGwE6apwfEURD7fDoq2BppB6K3tnOdeEhFGFtczrzG8bgfuPGoGfli6Uqle4h4lm7N/EQmvE92I7JRRZxV+vKDOwDxci1gK6hu8Ir9cWui65tc2WW3EToGS2kyZWq/EaUjUXTy1GgXnBC1cn31TmQ8mcQsrMjxjF/vSfMwKBgQCcCZrAmuXjK8YJ3v9aBhfdC1EViJBN1TFujTlPleHuIpZ4WStqEIXkNVFRRv4CVdbFjWa4NmTHShkhSV98oeUhLXxdx7VFjCo7v3ZEASnr8f+AZuSwk/Ln+FAZV2q6MjXwnqu3voNRsQsoXMQGHOLA9T1yKsxM1SlQloftN7lokQKBgCKjXCz0x7g+zthN7+GPXTPpIOjre0o0nb0jyHpgaCq24gHOvmgb/j1Psv2L4fZTyrfoue2G9G/8IEpl/WGNAzyCpuXSijpdIAV+c1BCHDqm9YEr7cRdUHdiaL06V4+Ltn4BGkSiP0mmnN65IE9NF3DawcxWUWMxrK/Ox9irt2v1AoGAfERF43g49vdoi3n2ANrzbE3T8ING8UWFTZbY+qHSQZV4IjZZlem8x+cScNlJ99Am8EPRd4mSLwi7BMBrdFV2pjqUXhdrLQ0YoWa0qCoJGegrZDYNkPbyr30ZRWVSESFlxdCHzxjBenC2AxoF3xxoFeX5Xo/pDpOAiLapX+lOFpECgYEAyWx9OzBF5QFH+ZRsiUJpYdtNIiNMHRNiix0R2/hgITGuSYKDJiPmCmKJX+Jz5c2BY4RC/Fhv4CZIMbGV2sTJysuhk1RSZMqJoQiTQT9ezlHhc8E2D1hprryEkgkWnqpK7zYsvrpvgJUiMVA7mtcans2MbKXQkmBku4nd3lRrars=";
    
    NSData *publicKeyData = [publicKey base64Data];
    NSString *publicKeyHex = [publicKeyData hexString];
    
    NSData *privateKeyData = [privateKey base64Data];
    NSString *privateKeyHex = [privateKeyData hexString];
    
    DMEPullConfiguration *configuration = [[DMEPullConfiguration alloc] initForOngoingAccessWithAppId:appId contractId:contractId publicKeyHex:publicKeyHex privateKeyHex:privateKeyHex];
    configuration.debugLogEnabled = YES;
    configuration.baseUrl = @"https://api.integration.devdigi.me/";
    return configuration;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
