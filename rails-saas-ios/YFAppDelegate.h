//
//  YFAppDelegate.h
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YFAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (YFAppDelegate *)sharedAppDelegate;
- (void)applyStylesheet;

@end
