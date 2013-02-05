//
//  YFEditProductViewController.h
//  rails-saas-ios
//
//  Created by Chris Richards on 05/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

@class YFProduct;

@interface YFEditProductViewController : UITableViewController<UITextFieldDelegate>

// @property (nonatomic, strong) YFProduct *product;

@property (nonatomic, strong, readonly) UITextField *identifierTextField;
@property (nonatomic, strong, readonly) UITextField *nameTextField;
@property (nonatomic, strong, readonly) UITextField *descriptionTextField;
@property (nonatomic, strong, readonly) UITextField *quantityTextField;

+ (CGFloat)textFieldWith;

- (void)create:(id)sender;
- (void)cancel:(id)sender;

@end
