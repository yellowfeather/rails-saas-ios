//
//  YFProductsViewController.m
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFAppDelegate.h"
#import "YFProductsViewController.h"
#import "YFProductTableViewCell.h"
#import "YFRailsSaasApiClient.h"
#import "YFSignInViewController.h"

@implementation YFProductsViewController {
__strong UIActivityIndicatorView *_activityIndicatorView;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	UIImageView *title = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav-title"]];
    title.accessibilityLabel = @"Rails SaaS";
	title.frame = CGRectMake(0.0f, 0.0f, 116.0f, 21.0f);
	self.navigationItem.titleView = title;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign out" style:UIBarButtonItemStyleBordered target:self action:@selector(signOut)];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		[self _checkUser];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self _checkUser];
	}

	[SSRateLimit executeBlock:^{
		[self refresh:nil];
	} name:@"refresh-products" limit:30.0];
}

#pragma mark - SSManagedViewController

- (Class)entityClass {
	return [YFProduct class];
}

#pragma mark - SSManagedTableViewController

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	YFProduct *product = [self objectForViewIndexPath:indexPath];
	[(YFProductTableViewCell *)cell setProduct:product];
}

#pragma mark - Actions

- (void)refresh:(id)sender {
    YFRailsSaasApiClient *client = [YFRailsSaasApiClient sharedClient];
	if (self.loading || [client isSignInRequired]) {
		return;
	}
	
	self.loading = YES;
	[client getProductsWithSuccess:^(AFJSONRequestOperation *operation, id responseObject) {
		dispatch_async(dispatch_get_main_queue(), ^{
			self.loading = NO;
		});
	} failure:^(AFJSONRequestOperation *operation, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[SSRateLimit resetLimitForName:@"refresh-products"];
			self.loading = NO;
		});
	}];
}


- (void)_checkUser {
	if ([[YFRailsSaasApiClient sharedClient] isSignInRequired]) {
		UIViewController *viewController = [[YFSignInViewController alloc] init];
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			[self.splitViewController presentViewController:navigationController animated:YES completion:nil];
		} else {
			[self.navigationController presentViewController:navigationController animated:NO completion:nil];
		}
		return;
	}
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *const cellIdentifier = @"cellIdentifier";
    
	YFProductTableViewCell *cell = (YFProductTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[YFProductTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    	[cell setEditingAction:@selector(_beginEditingWithGesture:) forTarget:self];
	}
	
	cell.product = [self objectForViewIndexPath:indexPath];
	
	return cell;
}

- (IBAction)signOut:(id)sender {
    [[YFRailsSaasApiClient sharedClient] signOut];
    [self _checkUser];
}

@end
