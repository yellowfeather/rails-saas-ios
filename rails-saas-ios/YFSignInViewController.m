//
//  YFViewController.m
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFHUDView.h"
#import "UIColor+RailsSaasiOSAdditions.h"
#import "UIFont+RailsSaasiOSAdditions.h"
#import "YFSignInViewController.h"
#import "YFRailsSaasApiClient.h"

@interface YFSignInViewController ()
- (void)_toggleMode:(id)sender;
- (void)_toggleModeAnimated:(BOOL)animated;
- (void)_configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)_validateButton;
@end

@implementation YFSignInViewController {
	UIButton *_footerButton;
	BOOL _signUpMode;
}

@synthesize emailTextField = _emailTextField;
@synthesize passwordTextField = _passwordTextField;

- (UITextField *)emailTextField {
	if (!_emailTextField) {
		_emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [[self class] textFieldWith], 30.0f)];
		_emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
		_emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		_emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		_emailTextField.textColor = [UIColor railsSaasBlueColor];
		_emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_emailTextField.delegate = self;
		_emailTextField.returnKeyType = UIReturnKeyNext;
		_emailTextField.placeholder = @"Your email address";
		_emailTextField.font = [UIFont railsSaasInterfaceFontOfSize:18.0f];
	}
	return _emailTextField;
}


- (UITextField *)passwordTextField {
	if (!_passwordTextField) {
		_passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [[self class] textFieldWith], 30.0f)];
		_passwordTextField.secureTextEntry = YES;
		_passwordTextField.textColor = [UIColor railsSaasBlueColor];
		_passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_passwordTextField.delegate = self;
		_passwordTextField.returnKeyType = UIReturnKeyGo;
		_passwordTextField.font = [UIFont railsSaasInterfaceFontOfSize:18.0f];
	}
	return _passwordTextField;
}


#pragma mark - Class Methods

+ (CGFloat)textFieldWith {
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 360.0f : 180.0f;
}


#pragma mark - NSObject

- (id)init {
	if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
		self.title = @"Rails Saas";
		UIImageView *title = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav-title"]];
		title.frame = CGRectMake(0.0f, 0.0f, 116.0f, 21.0f);
		self.navigationItem.titleView = title;
	}
	return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIView *background = [[UIView alloc] initWithFrame:CGRectZero];
	background.backgroundColor = [UIColor railsSaasArchesColor];
	self.tableView.backgroundView = background;
    
	_footerButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 34.0f)];
	[_footerButton setTitleColor:[UIColor railsSaasBlueColor] forState:UIControlStateNormal];
	[_footerButton setTitleColor:[UIColor railsSaasTextColor] forState:UIControlStateHighlighted];
	[_footerButton addTarget:self action:@selector(_toggleMode:) forControlEvents:UIControlEventTouchUpInside];
	_footerButton.titleLabel.font = [UIFont railsSaasInterfaceFontOfSize:16.0f];
	self.tableView.tableFooterView = _footerButton;
    
	_signUpMode = YES;
	[self _toggleModeAnimated:NO];
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
	// TODO: Terrible hack
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.emailTextField becomeFirstResponder];
	});
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return YES;
	}
	
	return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}


#pragma mark - Actions

- (void)signIn:(id)sender {
	if (!self.navigationItem.rightBarButtonItem.enabled) {
		return;
	}
    
	YFHUDView *hud = [[YFHUDView alloc] initWithTitle:@"Signing in..." loading:YES];
	[hud show];
    
    YFRailsSaasApiClient *client = [YFRailsSaasApiClient sharedClient];
    [client authenticateWithUsernameAndPassword:self.emailTextField.text
                                       password:self.passwordTextField.text
                                        success:^(AFOAuthCredential *credential) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [hud completeAndDismissWithTitle:@"Signed In!"];
                                                [self dismissViewControllerAnimated:YES completion:nil];
                                            });
                                        }
                                        failure:^(NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [hud failAndDismissWithTitle:@"Failed"];
                                                
                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                [alert show];
                                            });
                                        }];
}


- (void)signUp:(id)sender {
	if (!self.navigationItem.rightBarButtonItem.enabled) {
		return;
	}
	
	YFHUDView *hud = [[YFHUDView alloc] initWithTitle:@"Signing up..." loading:YES];
	[hud show];
    
//	[[YFRailsSaasApiClient sharedClient] signUpWithUsername:self.usernameTextField.text email:self.emailTextField.text password:self.passwordTextField.text success:^(AFJSONRequestOperation *operation, id responseObject) {
//		dispatch_async(dispatch_get_main_queue(), ^{
//			[hud completeAndDismissWithTitle:@"Signed Up!"];
//			[self.navigationController dismissModalViewControllerAnimated:YES];
//		});
//	} failure:^(AFJSONRequestOperation *operation, NSError *error) {
//		NSString *message = [[operation responseJSON] objectForKey:@"error_description"];
//        
//		dispatch_async(dispatch_get_main_queue(), ^{
//			[hud failAndDismissWithTitle:@"Failed"];
//            
//			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//			[alert show];
//		});
//	}];
}


- (void)forgot:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://rails-saas.com/forgot"]];
}


#pragma mark - Private

- (void)_toggleMode:(id)sender {
	[self _toggleModeAnimated:YES];
}


- (void)_toggleModeAnimated:(BOOL)animated {
	// Switch to sign in
	if (_signUpMode) {
		_signUpMode = NO;
        
		[_footerButton setTitle:@"Don't have an account? Sign Up →" forState:UIControlStateNormal];
        
		self.emailTextField.placeholder = @"Email address";
		self.passwordTextField.placeholder = @"Your password";
                
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonItemStyleBordered target:self action:@selector(signIn:)];
	}
    
	// Switch to sign up
	else {
		_signUpMode = YES;
        
		[_footerButton setTitle:@"Already have an account? Sign In →" forState:UIControlStateNormal];
        
		self.emailTextField.placeholder = @"Email address";
		self.passwordTextField.placeholder = @"Choose a password";
        
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Up" style:UIBarButtonItemStyleBordered target:self action:@selector(signUp:)];
	}
    
	[self _validateButton];
}


- (void)_configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		cell.textLabel.text = @"Email";
		cell.accessoryView = self.emailTextField;
		return;
	}
    
	cell.textLabel.text = @"Password";
	cell.accessoryView = self.passwordTextField;
}


- (void)_validateButton {
	BOOL valid = self.emailTextField.text.length >= 5 && self.passwordTextField.text.length >= 6;
	self.navigationItem.rightBarButtonItem.enabled = valid;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *const cellIdentifier = @"cellIdentifier";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.textColor = [UIColor railsSaasTextColor];
		cell.textLabel.font = [UIFont railsSaasInterfaceFontOfSize:18.0f];
	}
    
	[self _configureCell:cell atIndexPath:indexPath];
    
	return cell;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	// TODO: Terrible hack #shipit
	dispatch_async(dispatch_get_main_queue(), ^{
		[self _validateButton];
	});
	return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
		[self.passwordTextField becomeFirstResponder];
	} else if (textField == self.passwordTextField) {
		if (_signUpMode) {
			[self signUp:textField];
		} else {
			[self signIn:textField];
		}
	}
	return NO;
}

@end
