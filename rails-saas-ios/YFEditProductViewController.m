//
//  YFEditProductViewController.m
//  rails-saas-ios
//
//  Created by Chris Richards on 05/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "UIColor+RailsSaasiOSAdditions.h"
#import "UIFont+RailsSaasiOSAdditions.h"
#import "YFEditProductViewController.h"
#import "YFHUDView.h"
#import "Product.h"

@interface YFEditProductViewController ()

@end

@implementation YFEditProductViewController

@synthesize product;
@synthesize identifierTextField = _identifierTextField;
@synthesize nameTextField = _nameTextField;
@synthesize descriptionTextField = _descriptionTextField;
@synthesize quantityTextField = _quantityTextField;

- (UITextField *)identifierTextField {
	if (!_identifierTextField) {
		_identifierTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [[self class] textFieldWith], 30.0f)];
		_identifierTextField.keyboardType = UIKeyboardTypeNumberPad;
		_identifierTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		_identifierTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		_identifierTextField.textColor = [UIColor railsSaasBlueColor];
		_identifierTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_identifierTextField.delegate = self;
		_identifierTextField.returnKeyType = UIReturnKeyNext;
		_identifierTextField.placeholder = @"Identifier";
		_identifierTextField.font = [UIFont railsSaasInterfaceFontOfSize:18.0f];
	}
	return _identifierTextField;
}

- (UITextField *)nameTextField {
	if (!_nameTextField) {
		_nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [[self class] textFieldWith], 30.0f)];
		_nameTextField.keyboardType = UIKeyboardTypeDefault;
		_nameTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
		_nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		_nameTextField.textColor = [UIColor railsSaasBlueColor];
		_nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_nameTextField.delegate = self;
		_nameTextField.returnKeyType = UIReturnKeyNext;
		_nameTextField.placeholder = @"Name";
		_nameTextField.font = [UIFont railsSaasInterfaceFontOfSize:18.0f];
	}
	return _nameTextField;
}

- (UITextField *)descriptionTextField {
	if (!_descriptionTextField) {
		_descriptionTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [[self class] textFieldWith], 30.0f)];
		_descriptionTextField.keyboardType = UIKeyboardTypeDefault;
		_descriptionTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
		_descriptionTextField.autocorrectionType = UITextAutocorrectionTypeYes;
		_descriptionTextField.textColor = [UIColor railsSaasBlueColor];
		_descriptionTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_descriptionTextField.delegate = self;
		_descriptionTextField.returnKeyType = UIReturnKeyNext;
		_descriptionTextField.placeholder = @"Description";
		_descriptionTextField.font = [UIFont railsSaasInterfaceFontOfSize:18.0f];
	}
	return _descriptionTextField;
}

- (UITextField *)quantityTextField {
	if (!_quantityTextField) {
		_quantityTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [[self class] textFieldWith], 30.0f)];
		_quantityTextField.keyboardType = UIKeyboardTypeNumberPad;
		_quantityTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		_quantityTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		_quantityTextField.textColor = [UIColor railsSaasBlueColor];
		_quantityTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_quantityTextField.delegate = self;
		_quantityTextField.returnKeyType = UIReturnKeyDone;
		_quantityTextField.placeholder = @"Quantity";
		_quantityTextField.font = [UIFont railsSaasInterfaceFontOfSize:18.0f];
	}
	return _quantityTextField;
}

- (void)configureView
{
    if (![self product]) {
        return;
    }

    self.identifierTextField.text = product.identifier;
    self.nameTextField.text = product.name;
    self.descriptionTextField.text = product.desc;
    self.quantityTextField.text = [product.quantity stringValue];
}

#pragma mark - Class Methods

+ (CGFloat)textFieldWith {
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 360.0f : 180.0f;
}

#pragma mark - NSObject

- (id)init {
	return (self = [super initWithStyle:UITableViewStyleGrouped]);
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    [self configureView];

	if (self.product) {
		self.title = @"Edit Product";
	} else {
		self.title = @"New Product";
	}
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:(self.product ? @"Save" : @"Create") style:UIBarButtonItemStyleDone target:self action:@selector(create:)];
	
	UIView *background = [[UIView alloc] initWithFrame:CGRectZero];
	background.backgroundColor = [UIColor railsSaasArchesColor];
	self.tableView.backgroundView = background;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.identifierTextField becomeFirstResponder];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return YES;
	}
	
	return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}


#pragma mark - Actions

- (void)create:(id)sender {
    // todo: validation
    
	self.identifierTextField.enabled = NO;
    
	YFHUDView *hud = [[YFHUDView alloc] initWithTitle:(self.product ? @"Saving..." : @"Creating...") loading:YES];
	[hud show];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Product *newProduct;
        if (self.product) {
            newProduct = (Product *)[localContext existingObjectWithID:self.product.objectID error:nil];
        }
        else {
            newProduct = [Product createInContext:localContext];
        }
        newProduct.identifier = self.identifierTextField.text;
        newProduct.name = self.nameTextField.text;
        newProduct.desc = self.descriptionTextField.text;
        newProduct.quantity = self._getQuantity;
    }
    completion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Error: %@", error);
        }
        [hud completeAndDismissWithTitle:success ? (self.product ? @"Saved" : @"Created!") : @"Failed"];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
}


- (void)cancel:(id)sender {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)_configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		cell.textLabel.text = @"Identifier";
		cell.accessoryView = self.identifierTextField;
		return;
	}
	else if (indexPath.row == 1) {
		cell.textLabel.text = @"Name";
		cell.accessoryView = self.nameTextField;
		return;
	}
	else if (indexPath.row == 2) {
		cell.textLabel.text = @"Description";
		cell.accessoryView = self.descriptionTextField;
		return;
	}
	else if (indexPath.row == 3) {
		cell.textLabel.text = @"Quantity";
		cell.accessoryView = self.quantityTextField;
		return;
	}
}

- (NSNumber*)_getQuantity {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterNoStyle];
    return [formatter numberFromString:self.quantityTextField.text];
}

- (void)_validateButton {
	BOOL valid = self.identifierTextField.text.length >= 1 &&
                    self.nameTextField.text.length >= 1 &&
                    self.descriptionTextField.text.length >= 1 &&
                    self.quantityTextField.text.length >= 1;
	self.navigationItem.rightBarButtonItem.enabled = valid;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
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
    if (textField == self.identifierTextField) {
		[self.nameTextField becomeFirstResponder];
	} else if (textField == self.nameTextField) {
		[self.descriptionTextField becomeFirstResponder];
    } else if (textField == self.descriptionTextField) {
        [self.quantityTextField becomeFirstResponder];
    } else {
        [self create:textField];
    }
	return NO;
}

@end
