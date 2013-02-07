//
//  YFManagedTableViewController.h
//  rails-saas-ios
//
//  Created by Chris Richards on 04/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFPullToRefreshView.h"

@interface YFManagedTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, SSPullToRefreshViewDelegate>

@property (nonatomic, strong, readonly) YFPullToRefreshView *pullToRefreshView;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, assign, getter=isLoading) BOOL loading;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (NSString *)entityName;
- (NSManagedObjectContext *)managedObjectContext;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)refresh:(id)sender;

- (void)setLoading:(BOOL)loading animated:(BOOL)animated;
- (void)showLoadingView:(BOOL)animated;
- (void)hideLoadingView:(BOOL)animated;

@end
