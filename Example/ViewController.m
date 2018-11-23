//
//  ViewController.m
//  CASDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "ViewController.h"
#import "LogViewController.h"

@import DigiMeSDK;

@interface ViewController () <DMEClientAuthorizationDelegate, DMEClientDownloadDelegate>

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
    self.dmeClient.authorizationDelegate = self;
    self.dmeClient.downloadDelegate = self;
    
    // - GET STARTED -
    
    // - INSERT your App ID here -
    self.dmeClient.appId = @"YOUR_APP_ID";
    
    // - REPLACE 'YOUR_P12_PASSWORD' with password provided by Digi.me Ltd
    self.dmeClient.privateKeyHex = [DMECryptoUtilities privateKeyHexFromP12File:@"CA_RSA_PRIVATE_KEY" password:@"YOUR_P12_PASSWORD"];
    
    self.dmeClient.contractId = @"gzqYsbQ1V1XROWjmqiFLcH2AF1jvcKcg";
    
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
    [self.dmeClient authorize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DMEClientAuthorizationDelegate
-(void)sessionCreated:(CASession *)session
{
    [self.logVC logMessage:[NSString stringWithFormat:@"Session created: %@", session.sessionKey]];
}

-(void)sessionCreateFailed:(NSError *)error
{
    [self.logVC logMessage:[NSString stringWithFormat:@"Session created failed: %@", error.localizedDescription]];
}

-(void)authorizeSucceeded:(CASession *)session
{
    [self.logVC logMessage:[NSString stringWithFormat:@"Authorization Succeeded for session: %@", session.sessionKey]];
    
    [self.dmeClient getFileList];
    [self.dmeClient getAccounts];
}

-(void)authorizeDenied:(NSError *)error
{
    [self.logVC logMessage:[NSString stringWithFormat:@"Authorization denied: %@", error.localizedDescription]];
}

-(void)authorizeFailed:(NSError *)error
{
    [self.logVC logMessage:[NSString stringWithFormat:@"Authorization failed: %@", error.localizedDescription]];
}

#pragma mark - DMEClientDownloadDelegate
-(void)clientFailedToRetrieveFileList:(NSError *)error
{
    [self.logVC logMessage:[NSString stringWithFormat:@"Client retrieve fileList failed: %@", error.localizedDescription]];
}

-(void)clientRetrievedFileList:(CAFiles *)files
{
    self.fileCount = files.fileIds.count;
    
    for (NSString *fileId in files.fileIds)
    {
        [self.dmeClient getFileWithId:fileId];
    }
}

-(void)fileRetrieved:(CAFile *)file
{
    self.progress++;
    
    [self.logVC logMessage:[NSString stringWithFormat:@"File Content: %@", file.json]];
    [self. logVC logMessage:[NSString stringWithFormat:@"--------------------Progress: %i/%i", (int)self.progress, (int)self.fileCount]];
}

-(void)fileRetrieveFailed:(NSString *)fileId error:(NSError *)error
{
    [self.logVC logMessage:[NSString stringWithFormat:@"Failed to retrieve content for fileId: < %@ > Error: %@", fileId, error.localizedDescription]];
}

- (void)accountsRetreived:(CAAccounts *)accounts
{
    [self.logVC logMessage:[NSString stringWithFormat:@"Account Content: %@", accounts.json]];
}

- (void)accountsRetrieveFailed:(NSError *)error
{
    [self.logVC logMessage:[NSString stringWithFormat:@"Failed to retrieve accounts: %@", error.localizedDescription]];
}

#pragma mark - DMEClientPostboxDelegate
- (void)postboxCreationFailed:(NSError *)error
{
    [self.logVC logMessage:[NSString stringWithFormat:@"Failed to create postbox: %@", error.localizedDescription]];
}

@end
