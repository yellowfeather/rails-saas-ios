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

- (NSString *)entityName {
    return @"Product";
}

#pragma mark - NSObject

- (void)viewDidLoad {
	[super viewDidLoad];
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

#pragma mark - Actions

- (void)refresh:(id)sender {
    YFRailsSaasApiClient *client = [YFRailsSaasApiClient sharedClient];
	if ([client isSignInRequired]) {
		return;
	}

	self.loading = YES;
	[client getProductsWithSuccess:^(AFJSONRequestOperation *operation, id responseObject) {
		dispatch_async(dispatch_get_main_queue(), ^{
			self.loading = NO;

            [self.managedObjectContext performBlockAndWait:^{
                NSArray *productsFromResponse = [responseObject valueForKeyPath:@"response"];
        
                for (NSDictionary *dictionary in productsFromResponse) {

                    NSNumber *productId = dictionary[@"id"];
                    
                    NSFetchRequest *fetchRequest = [[self fetchedResultsController] fetchRequest];
                    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"productId = %@", productId];
                    fetchRequest.fetchLimit = 1;
                    
                    // Execute the fetch request
                    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
                    
                    // If the object is not found, return nil
                    if (results.count == 0) {
                        NSLog(@"Inserting product: %@", productId);
                        YFProduct *product = [NSEntityDescription insertNewObjectForEntityForName:@"Product"
                                                                           inManagedObjectContext:self.managedObjectContext];
                        [product unpackDictionary:dictionary];
                        [self.managedObjectContext save:nil];
                    }
                    else {
                        NSLog(@"Skip product: %@", productId);
                    }
                }
            }];
		});
	} failure:^(AFJSONRequestOperation *operation, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[SSRateLimit resetLimitForName:@"refresh-products"];
			self.loading = NO;
		});
	}];
}

- (void)createProduct:(id)sender {
	YFEditProductViewController *viewController = [[YFEditProductViewController alloc] init];
    viewController.managedObjectContext = self.managedObjectContext;
    
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

- (YFProduct *)_findProductWithId:(NSNumber *)productId
{
    // Create the fetch request for the ID
    NSFetchRequest *fetchRequest = [[self fetchedResultsController] fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"productId = %@", productId];
    fetchRequest.fetchLimit = 1;
    
    // Execute the fetch request
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    // If the object is not found, return nil
    if (results.count == 0) {
        return nil;
    }

	return [results objectAtIndex:0];
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
	
    YFProduct *product = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	cell.product = product;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) return;
    
    // id object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    // [[self editViewController] setProduct:object];
}

#pragma mark - Fetched results controller

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
{
	YFProduct *product = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	[(YFProductTableViewCell *)cell setProduct:product];
}

#pragma mark

- (void)deleteAllProducts {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Product" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items) {
    	[self.managedObjectContext deleteObject:managedObject];
    }
    
    if (![self.managedObjectContext save:&error]) {
    	NSLog(@"Error deleting product - error:%@",error);
    }
}

@end
