//
//  YFAppDelegate.m
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "UIFont+RailsSaasiOSAdditions.h"
#import "YFAppDelegate.h"
#import "YFProductsViewController.h"
#import "YFRailsSaasApiClient.h"
#import "YFSettingsFontPickerViewController.h"
#import "YFSettingsTextSizePickerViewController.h"

@implementation YFAppDelegate

@synthesize window = _window;


+ (YFAppDelegate *)sharedAppDelegate {
	return (YFAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Model.sqlite"];
    
	// Default defaults
	NSDictionary *defaults = @{
                            // kYFTapActionDefaultsKey: kYFTapActionCompleteKey,
                            kYFFontDefaultsKey: kYFFontGothamKey,
                            kYFTextSizeDefaultsKey: kYFTextSizeMediumKey
                            };
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
	// Initialize the window
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.backgroundColor = [UIColor blackColor];
	
	[self applyStylesheet];
	
//	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//		self.window.rootViewController = [[CDISplitViewController alloc] init];
//	} else {
		YFProductsViewController *viewController = [[YFProductsViewController alloc] init];
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		self.window.rootViewController = navigationController;
//	}
    
	[self.window makeKeyAndVisible];
	
	// Defer some stuff to make launching faster
	dispatch_async(dispatch_get_main_queue(), ^{
		// Setup status bar network indicator
		[AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
	});
    
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [MagicalRecord cleanUp];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    exit(0);
}

#pragma mark - Stylesheet

- (void)applyStylesheet {
	// Navigation bar
	UINavigationBar *navigationBar = [UINavigationBar appearance];
	[navigationBar setBackgroundImage:[UIImage imageNamed:@"nav-background"] forBarMetrics:UIBarMetricsDefault];
	[navigationBar setTitleVerticalPositionAdjustment:-1.0f forBarMetrics:UIBarMetricsDefault];
	[navigationBar setTitleTextAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:
										   [UIFont railsSaasInterfaceFontOfSize:20.0f], UITextAttributeFont,
										   [UIColor colorWithWhite:0.0f alpha:0.2f], UITextAttributeTextShadowColor,
										   [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
										   [UIColor whiteColor], UITextAttributeTextColor,
										   nil]];
	
	// Navigation bar mini
	[navigationBar setTitleVerticalPositionAdjustment:-2.0f forBarMetrics:UIBarMetricsLandscapePhone];
	[navigationBar setBackgroundImage:[UIImage imageNamed:@"nav-background-mini"] forBarMetrics:UIBarMetricsLandscapePhone];
	
	// Navigation button
	NSDictionary *barButtonTitleTextAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
												  [UIFont railsSaasInterfaceFontOfSize:14.0f], UITextAttributeFont,
												  [UIColor colorWithWhite:0.0f alpha:0.2f], UITextAttributeTextShadowColor,
												  [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
												  nil];
	UIBarButtonItem *barButton = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
	//	[barButton setTitlePositionAdjustment:UIOffsetMake(0.0f, 1.0f) forBarMetrics:UIBarMetricsDefault];
	[barButton setTitleTextAttributes:barButtonTitleTextAttributes forState:UIControlStateNormal];
	[barButton setTitleTextAttributes:barButtonTitleTextAttributes forState:UIControlStateHighlighted];
	[barButton setBackgroundImage:[[UIImage imageNamed:@"nav-button"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	[barButton setBackgroundImage:[[UIImage imageNamed:@"nav-button-highlighted"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
	
	// Navigation back button
	[barButton setBackButtonTitlePositionAdjustment:UIOffsetMake(2.0f, -2.0f) forBarMetrics:UIBarMetricsDefault];
	[barButton setBackButtonBackgroundImage:[[UIImage imageNamed:@"nav-back"] stretchableImageWithLeftCapWidth:13 topCapHeight:0] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	[barButton setBackButtonBackgroundImage:[[UIImage imageNamed:@"nav-back-highlighted"] stretchableImageWithLeftCapWidth:13 topCapHeight:0] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
	
	// Navigation button mini
	//	[barButton setTitlePositionAdjustment:UIOffsetMake(0.0f, 1.0f) forBarMetrics:UIBarMetricsLandscapePhone];
	[barButton setBackgroundImage:[[UIImage imageNamed:@"nav-button-mini"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
	[barButton setBackgroundImage:[[UIImage imageNamed:@"nav-button-mini-highlighted"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
	
	// Navigation back button mini
	[barButton setBackButtonTitlePositionAdjustment:UIOffsetMake(2.0f, -2.0f) forBarMetrics:UIBarMetricsLandscapePhone];
	[barButton setBackButtonBackgroundImage:[[UIImage imageNamed:@"nav-back-mini"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
	[barButton setBackButtonBackgroundImage:[[UIImage imageNamed:@"nav-back-mini-highlighted"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
	
	// Toolbar
	UIToolbar *toolbar = [UIToolbar appearance];
	[toolbar setBackgroundImage:[UIImage imageNamed:@"navigation-background"] forToolbarPosition:UIToolbarPositionTop barMetrics:UIBarMetricsDefault];
	[toolbar setBackgroundImage:[UIImage imageNamed:@"toolbar-background"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
	
	// Toolbar mini
	[toolbar setBackgroundImage:[UIImage imageNamed:@"navigation-background-mini"] forToolbarPosition:UIToolbarPositionTop barMetrics:UIBarMetricsLandscapePhone];
	[toolbar setBackgroundImage:[UIImage imageNamed:@"toolbar-background-mini"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsLandscapePhone];
}

@end
