//
//  YFViewController.m
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFLoginViewController.h"
#import "YFRailsSaasApiClient.h"

@interface YFLoginViewController ()

@end

@implementation YFLoginViewController

//  Synthesize accessors
@synthesize usernameField, passwordField;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

//  When the view reappears after logout we want to wipe the username and password fields
- (void)viewWillAppear:(BOOL)animated
{
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    
    [usernameField setText:@""];
    [passwordField setText:@""];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)login:(id)sender {
    NSString *username = [usernameField text];
    NSString *password = [passwordField text];
    
    YFRailsSaasApiClient *client = [YFRailsSaasApiClient sharedClient];
    [client authenticateWithUsernameAndPassword:username
                                       password:password
                                        success:^(AFOAuthCredential *credential) {
                                            [AFOAuthCredential storeCredential:credential
                                                                withIdentifier:client.serviceProviderIdentifier];
                                            [self performSegueWithIdentifier:@"LoginSegue" sender:sender];
                                        }
                                        failure:^(NSError *error) {
                                            [passwordField setText:@""];
                                        }];
}

@end
