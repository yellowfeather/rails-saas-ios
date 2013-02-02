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

@interface YFProductsViewController ()
- (void)reload:(id)sender;
@end

@implementation YFProductsViewController {
__strong UIActivityIndicatorView *_activityIndicatorView;
}

@synthesize fetchedResultsController;
@synthesize managedObjectContext;

- (void) deleteAllProducts  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Product" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items) {
    	[managedObjectContext deleteObject:managedObject];
    }
    if (![managedObjectContext save:&error]) {
    	NSLog(@"Error deleting product - error:%@",error);
    }
}

- (void)reload:(id)sender {
    [_activityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self deleteAllProducts];
    
    [[YFRailsSaasApiClient sharedClient] setManagedObjectContext:managedObjectContext];
    
    [[YFRailsSaasApiClient sharedClient] getProductsWithSuccess:^(AFJSONRequestOperation *operation, id responseObject) {
                                                            [_activityIndicatorView stopAnimating];
                                                            self.navigationItem.rightBarButtonItem.enabled = YES;
                                                        }
                                                        failure:^(AFJSONRequestOperation *operation, NSError *error) {
                                                            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
                                                            [_activityIndicatorView stopAnimating];
                                                            self.navigationItem.rightBarButtonItem.enabled = YES;
                                                        }];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicatorView.hidesWhenStopped = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = NSLocalizedString(@"rails-saas iOS App", nil);
    
    // self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_activityIndicatorView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)];
    
    // [self reload:nil];
}

- (void)viewDidUnload
{
    _activityIndicatorView = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = [[self fetchedResultsController] sections];
    id <NSFetchedResultsSectionInfo> sectionInfo = nil;
    sectionInfo = [sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    YFProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[YFProductTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.product = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController) return fetchedResultsController;
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = nil;
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Product"];
    
    NSMutableArray *sortArray = [NSMutableArray array];
    [sortArray addObject:[[NSSortDescriptor alloc] initWithKey:@"name"
                                                     ascending:YES]];
    [fetchRequest setSortDescriptors:sortArray];
    
    NSFetchedResultsController *frc = nil;
    frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                              managedObjectContext:moc
                                                sectionNameKeyPath:nil
                                                         cacheName:@"Master"];
    
    [self setFetchedResultsController:frc];
    [[self fetchedResultsController] setDelegate:self];
    
	NSError *error = nil;
	ZAssert([[self fetchedResultsController] performFetch:&error],
            @"Unresolved error %@\n%@", [error localizedDescription],
            [error userInfo]);
    
    return fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sectionIndex];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertSections:indexSet
                            withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteSections:indexSet
                            withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
        {
            NSArray *newArray = [NSArray arrayWithObject:newIndexPath];
            [[self tableView] insertRowsAtIndexPaths:newArray
                                    withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete:
        {
            NSArray *oldArray = [NSArray arrayWithObject:indexPath];
            [[self tableView] deleteRowsAtIndexPaths:oldArray
                                    withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate:
        {
            YFProductTableViewCell *cell;
            cell = (YFProductTableViewCell *)[[self tableView] cellForRowAtIndexPath:indexPath];
            cell.product = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove:
        {
            NSArray *oldArray = [NSArray arrayWithObject:indexPath];
            [[self tableView] deleteRowsAtIndexPaths:oldArray
                                    withRowAnimation:UITableViewRowAnimationFade];
            NSArray *newArray = [NSArray arrayWithObject:newIndexPath];
            [[self tableView] insertRowsAtIndexPaths:newArray
                                    withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

- (NSString*)controller:(NSFetchedResultsController*)controller
sectionIndexTitleForSectionName:(NSString*)sectionName
{
    return [NSString stringWithFormat:@"[%@]", sectionName];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] endUpdates];
}

- (IBAction)logout:(id)sender {
    [[YFRailsSaasApiClient sharedClient] logout];
    
    YFAppDelegate *appDelegate = (YFAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showLoginView];
}

@end
