//
//  YFManagedTableViewController.h
//  rails-saas-ios
//
//  Created by Chris Richards on 04/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFPullToRefreshView.h"

@interface YFManagedTableViewController : SSManagedTableViewController <SSPullToRefreshViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong, readonly) YFPullToRefreshView *pullToRefreshView;
@property (nonatomic, strong, readonly) NSIndexPath *editingIndexPath;
@property (nonatomic, assign, readonly) CGRect keyboardRect;
@property (nonatomic, strong) UIView *coverView;

- (void)refresh:(id)sender;
- (void)toggleEditMode:(id)sender;
- (void)endCellTextEditing;
- (void)editRow:(UIGestureRecognizer *)editingGestureRecognizer;

- (void)updateTableViewOffsets;
- (void)keyboardDidShow:(NSNotification *)notification;
- (void)keyboardDidHide:(NSNotification *)notification;
- (void)reachabilityChanged:(NSNotification *)notification;

- (void)showCoverView;
- (BOOL)showingCoverView;
- (void)hideCoverView;
- (void)coverViewTapped:(id)sender;

@end
