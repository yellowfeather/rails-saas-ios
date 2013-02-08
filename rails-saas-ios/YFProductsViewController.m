//
//  YFProductsViewController.m
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFAppDelegate.h"
#import "YFEditProductViewController.h"
#import "YFProductsViewController.h"
#import "YFProductTableViewCell.h"
#import "YFRailsSaasApiClient.h"
#import "YFSignInViewController.h"
#import "YFSyncManager.h"

@interface YFProductsViewController ()

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation YFProductsViewController {
__strong UIActivityIndicatorView *_activityIndicatorView;
}

@synthesize editViewController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - NSObject

- (void)viewDidLoad {
	[super viewDidLoad];
    
    [self.fetchedResultsController managedObjectContext];
    
	UIImageView *title = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav-title"]];
    title.accessibilityLabel = @"Rails SaaS";
	title.frame = CGRectMake(0.0f, 0.0f, 116.0f, 21.0f);
	self.navigationItem.titleView = title;

    [super setEditing:NO animated:NO];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign out"
        style:UIBarButtonItemStyleBordered target:self action:@selector(signOut:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus"]
        style:UIBarButtonItemStyleBordered target:self action:@selector(createProduct:)];
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

#pragma mark - YFManagedTableViewController

- (NSFetchedResultsController *)createFetchedResultsController
{
    return [Product fetchAllGroupedBy:nil withPredicate:nil sortedBy:@"name" ascending:YES delegate:self];
}

#pragma mark - Actions

- (void)refresh:(id)sender {
	self.loading = YES;
    [[YFSyncManager shared] syncProductsWithBlock:^(BOOL success, NSError *error) {
        self.loading = NO;
    }];
}

- (void)createProduct:(id)sender {
	YFEditProductViewController *viewController = [[YFEditProductViewController alloc] init];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)signOut:(id)sender {
    [self deleteAllProducts];
    [[YFRailsSaasApiClient sharedClient] signOut];
    [self _checkUser];
}

#pragma - private

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

#pragma mark - Table View

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const cellIdentifier = @"ProductCellIdentifier";

    //    [self configureCell:cell atIndexPath:indexPath];

    YFProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
		cell = [[YFProductTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    	// [cell setEditingAction:@selector(_beginEditingWithGesture:) forTarget:self];
	}
	
    Product *product = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.product = product;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) return;
    
    id object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
	YFEditProductViewController *viewController = [[YFEditProductViewController alloc] init];
    viewController.product = object;
    
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Fetched results controller

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
{
	Product *product = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	[(YFProductTableViewCell *)cell setProduct:product];
}

#pragma mark

- (void)deleteAllProducts {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [Product truncateAllInContext:localContext];
    }];
}

@end
