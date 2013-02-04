//
//  YFViewController.h
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YFSignInViewController : UITableViewController<UITextFieldDelegate>

@property (nonatomic, strong, readonly) UITextField *emailTextField;
@property (nonatomic, strong, readonly) UITextField *passwordTextField;

+ (CGFloat)textFieldWith;

- (void)signIn:(id)sender;
- (void)signUp:(id)sender;
- (void)forgot:(id)sender;

@end
