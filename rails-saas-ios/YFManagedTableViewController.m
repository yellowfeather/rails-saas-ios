//
//  YFManagedTableViewController.m
//  rails-saas-ios
//
//  Created by Chris Richards on 04/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import <Reachability.h>
#import "YFManagedTableViewController.h"
#import "UIColor+RailsSaasiOSAdditions.h"
#import "YFLoadingView.h"
#import "YFTableViewCell.h"

@implementation YFManagedTableViewController {
	UITapGestureRecognizer *_tableViewTapGestureRecognizer;
	BOOL _allowScrolling;
}

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize loading = _loading;
@synthesize loadingView = _loadingView;
@synthesize pullToRefreshView = _pullToRefreshView;

- (NSString *)entityName {
	// Subclasses should override this method
    return nil;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	// Subclasses should override this method
}

- (void)setLoading:(BOOL)loading {
	[self setLoading:loading animated:YES];
}

#pragma mark - NSObject

- (void)dealloc {
    _fetchedResultsController = nil;
    
	_pullToRefreshView.delegate = nil;
	[_pullToRefreshView removeFromSuperview];
	_pullToRefreshView = nil;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    
    _fetchedResultsController = self.createFetchedResultsController;

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.rowHeight = [YFTableViewCell cellHeight];
	
	UIView *background = [[UIView alloc] initWithFrame:CGRectZero];
	background.backgroundColor = [UIColor railsSaasArchesColor];
	self.tableView.backgroundView = background;
	
	SSGradientView *footer = [[SSGradientView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 3.0f)];
	footer.backgroundColor = [UIColor clearColor];
	footer.colors = [NSArray arrayWithObjects:
					 [UIColor colorWithWhite:0.937f alpha:1.0f],
					 [UIColor colorWithWhite:0.937f alpha:0.0f],
					 nil];
	self.tableView.tableFooterView = footer;
	
	_tableViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endCellTextEditing)];
	_tableViewTapGestureRecognizer.enabled = NO;
	_tableViewTapGestureRecognizer.cancelsTouchesInView = NO;
	[self.tableView addGestureRecognizer:_tableViewTapGestureRecognizer];
	
	_pullToRefreshView = [[YFPullToRefreshView alloc] initWithScrollView:self.tableView delegate:self];
    
	self.loadingView = [[YFLoadingView alloc] initWithFrame:self.view.bounds];
	self.loadingView.userInteractionEnabled = NO;
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return YES;
	}
	
	return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}


#pragma mark - SSManagedViewController

- (void)setLoading:(BOOL)loading animated:(BOOL)animated {
	if (self.loading) {
		[self.pullToRefreshView startLoading];
	} else {
		[self.pullToRefreshView finishLoading];
	}
}


- (void)showLoadingView:(BOOL)animated {
	if (!self.loadingView || self.loadingView.superview) {
		return;
	}
	
	self.loadingView.alpha = 0.0f;
	self.loadingView.frame = self.view.bounds;
	[self.tableView addSubview:self.loadingView];
	
	void (^change)(void) = ^{
		self.loadingView.alpha = 1.0f;
	};
	
	
	if (animated) {
		[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:change completion:nil];
	} else {
		change();
	}
}

- (void)hideLoadingView:(BOOL)animated {
	if (!self.loadingView || !self.loadingView.superview) {
		return;
	}
    
	void (^change)(void) = ^{
		self.loadingView.alpha = 0.0f;
	};
    
	void (^completion)(BOOL finished) = ^(BOOL finished) {
		[self.loadingView removeFromSuperview];
	};
    
	if (animated) {
		[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:change completion:completion];
	} else {
		change();
		completion(YES);
	}
}

#pragma mark - Actions

- (void)refresh:(id)sender {
	// Subclasses should override this
}

- (NSFetchedResultsController *)createFetchedResultsController
{
    // subclasses should override this
    return nil;
}

#pragma mark - SSPullToRefreshViewDelegate

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view {
	[self refresh:view];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete) return;
    
    NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
    [context deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    _fetchedResultsController = self.createFetchedResultsController;

    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
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
            [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[[self tableView] cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] endUpdates];
}

@end
