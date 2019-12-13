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
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"digi.me" message:@"CHOOSE YOUR CA MODE" preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cyclic CA" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self runTappedForCyclicCA];
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"CA" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self runTapped];
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];

    [self.navigationController presentViewController:actionSheet animated:YES completion:nil];
}

- (void)runTappedForCyclicCA
{
    NSString *appId = @"GpSxfx3hmwWmxIlCPk0ECO0B6pMN0KZ2";
    NSString *contractId = @"RBRCQCAt72GQ69LHgPzby4eV09ok1PLi";
    NSString *publicKey = @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkaFsJNKJMjrUkJfU+56RUfURUYQcFvs2GunhJzUC1xyJxNt0a+AFCgCBpa6+uQgrkvbgVrz717v2hYbZ4HO/c5e7jNYIaV4kt+NBoEjjYnWp8nMdix98QrJw5ROga1h4JW3d8ldnUG35agG0gR2rkLvw1OgnhuhwnA4sG17mo5av4q4TKX62bKzCkFlT3z0FbYdkcz8Gleeb5WM1mvR3DC1mlmvsptDZ6bVLD18Z+fbpCzVrBg+RVR2qGR7Zuq3fejod9Nf8yQY+Njv0XYaC+zdGWJlY7CG4EBFh63JLBrbhJrpXiUMSldnOxMi/D91jR4wEI8oXlrS/7Jfv8ARJ5QIDAQAB";
    NSData *publicKeyData = [publicKey base64Data];
    NSString *publicKeyHex = [publicKeyData hexString];
    
    NSString *privateKey = @"MIIEpAIBAAKCAQEAkaFsJNKJMjrUkJfU+56RUfURUYQcFvs2GunhJzUC1xyJxNt0a+AFCgCBpa6+uQgrkvbgVrz717v2hYbZ4HO/c5e7jNYIaV4kt+NBoEjjYnWp8nMdix98QrJw5ROga1h4JW3d8ldnUG35agG0gR2rkLvw1OgnhuhwnA4sG17mo5av4q4TKX62bKzCkFlT3z0FbYdkcz8Gleeb5WM1mvR3DC1mlmvsptDZ6bVLD18Z+fbpCzVrBg+RVR2qGR7Zuq3fejod9Nf8yQY+Njv0XYaC+zdGWJlY7CG4EBFh63JLBrbhJrpXiUMSldnOxMi/D91jR4wEI8oXlrS/7Jfv8ARJ5QIDAQABAoIBAQCHFZwRv/UhUa7Q/PXD/P9BbbiFy6yeqKE0b9O5IZQj40XsA8DHO8KQ141rGV+ylOCOb1ADRUO6hpESpNa/O77QQ2PmLLcavggDRtseCd5Z+1kMGznBThBecdUEuKLqT+MKnRHudKLR2WEssq4zwkjddWfcpgfcPQoPx5mkPfBktrlCsPDy64tF3GEENkRnjFYb+C2xORmHVFTFkUKUJtlOppyLq3ibva8x+O6fZmsXPwXwirLyewsK4sp/8lwYQ0CVsPUUZhZHz5zxK8kzIbLIlQwqNsQ0/ujPT9ulkdm6qa3U7Ps8FLpz0d3RaU8lPsOZgAJ1PO933ijX9JlbxqdhAoGBAO13uBXrICSVvGD16ZhJsKfATahdXZM62jlxxI5tIqLBHAW0wKGXSiKfQ+Te27l5YveXdQQ2rXLCF2ctcz3SLFEkCHquhjMn8//TaKayXhNqRnFSkKuDK/tecEUT745x5hC2cXiQVYmKb6ltR5BWwjhaKkPzQJvfrX1VifyrxMl5AoGBAJz+7EnLY+vWrerN4xg3tUhr9KkgDBkUVtkACUMLZm4t3jzHNMgn+qlt27LfhjEw/9Ps51X5IOHe8q6hWS4HPeZ7Ant4KoluPj4p69k/W27lOkV8RUhQXcY8QwTXN9CYQSUBHpg2UF97gXOvU95CH+sjzvIu7lIK0KFNcz1eXZTNAoGAF/yr36rsiEWHzdOJURTAf3FxZrxno2Oif4L6c9iaUw5mojzr6Ga72lt0JD5Ou6GDWbc23sIXKyxn6Mgyh+AfEeMt6BaQ/8HdZ84XGB+UWSm3C+NnMawCWVXkyVWGMUFYGAAV3jPWMBqHxPmA7ReWbtLMyihcMmKZx7tIQPmo2yECgYBRJ95Rj1hJ06H33RJltHZ7x4Kj4rMeS8tRRZmEFOKQVhmp5Xg9d5019Fo7rxyZVTEKBk7XvH7pA+0DpNiK2KeA+1mfJdEnVdvLGrSWiw/i1ZA31zOhXBn9na0vVWm+5NXYISoFmR4XHasfeCSsohYJ4Wra+rOrqXeLypOlx6AsiQKBgQDokJgdgeIhMQqFRy99UtBEQhYnHzWLR2T87X1DsDbg+fK8m/JqRx127Xo3QZkA27fAHRdjn/qDcXhi31m3O4vytE703DRDfeqa9vvZkWZR3E/ye4G9DfH1okayXESahpRtRlGazj7V8liOOa0Sh2KoHlgeY7FuIEjaUB2KPz9Y+g==";
    NSData *privateKeyData = [privateKey base64Data];
    NSString *privateKeyHex = [privateKeyData hexString];
    
    self.configuration = [[DMEPullConfiguration alloc] initForOngoingAccessWithAppId:appId contractId:contractId publicKeyHex:publicKeyHex privateKeyHex:privateKeyHex];
    self.configuration.debugLogEnabled = YES;
    self.configuration.baseUrl = @"https://api.test09.devdigi.me/";
    
    if (self.configuration)
    {
        self.dmeClient = nil;
        self.dmeClient = [[DMEPullClient alloc] initWithConfiguration:self.configuration];
    }
    
    [self.logVC reset];
    
    DMEScope *scope = [self getScope];
    [self.dmeClient authorizeOngoingAccessWithScope:scope completion:^(DMESession * _Nullable session, DMEOAuthObject * _Nullable oAuthObject, NSError * _Nullable error) {
        
        if (session == nil)
        {
            [self.logVC logMessage:[NSString stringWithFormat:@"Authorization failed: %@", error.localizedDescription]];
            return;
        };
        
        [self.logVC logMessage:[NSString stringWithFormat:@"Authorization Succeeded for session: %@", session.sessionKey]];
        [self.logVC logMessage:[NSString stringWithFormat:@"OAuth access token: %@", oAuthObject.accessToken]];
        [self.logVC logMessage:[NSString stringWithFormat:@"OAuth refresh token: %@", oAuthObject.refreshToken]];
        [self.logVC logMessage:[NSString stringWithFormat:@"OAuth expiration date: %@", oAuthObject.expiresOn]];
    }];
}

- (void)runTapped
{
    // - GET STARTED CA FLOW -
    
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

    if (self.configuration)
    {
        self.dmeClient = nil;
        self.dmeClient = [[DMEPullClient alloc] initWithConfiguration:self.configuration];
    }
    
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

- (DMEScope *)getScope
{
    NSMutableArray *serviceObjectTypes = [NSMutableArray new];
    for (int i = 1; i <= 60; i++)
    {
        DMEServiceObjectType *serviceObjectType = [[DMEServiceObjectType alloc]initWithIdentifier:i];
        [serviceObjectTypes addObject:serviceObjectType];
    }
    
    DMEServiceType *serviceType0 = [[DMEServiceType alloc] initWithIdentifier:1 objectTypes: serviceObjectTypes];
    DMEServiceType *serviceType1 = [[DMEServiceType alloc] initWithIdentifier:3 objectTypes: serviceObjectTypes];
    DMEServiceType *serviceType2 = [[DMEServiceType alloc] initWithIdentifier:4 objectTypes: serviceObjectTypes];
    NSArray *serviceTypes1 = [NSArray arrayWithObjects: serviceType0, serviceType1, serviceType2, nil];
    DMEServiceGroup *serviceGroup1 = [[DMEServiceGroup alloc] initWithIdentifier:1 serviceTypes:serviceTypes1];

    DMEScope *scope = [[DMEScope alloc] init];
    scope.serviceGroups = [NSArray arrayWithObjects: serviceGroup1, nil];
    
    NSDate *to = [NSDate date];
    NSUInteger componentFlags = NSCalendarUnitYear;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:componentFlags fromDate:to];
    [components setYear:-1];
    NSDate *from = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:to options:0];
    
    DMETimeRange *range = [DMETimeRange from:from to:to];
    scope.timeRanges = [NSArray arrayWithObjects:range, nil];
    return scope;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
