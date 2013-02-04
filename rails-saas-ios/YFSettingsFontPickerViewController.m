//
//  YFSettingsFontPickerViewController.m
//  rails-saas-ios
//
//  Created by Chris Richards on 04/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFSettingsFontPickerViewController.h"
#import "UIFont+RailsSaasiOSAdditions.h"
#import <SSToolkit/NSString+SSToolkitAdditions.h>

NSString *const kYFFontDefaultsKey = @"YFFontDefaults";
NSString *const kYFFontGothamKey = @"Gotham";
NSString *const kYFFontHelveticaNeueKey = @"HelveticaNeue";
NSString *const kYFFontHoeflerKey = @"Hoefler";
NSString *const kYFFontAvenirKey = @"Avenir";

@implementation YFSettingsFontPickerViewController

#pragma mark - Class Methods

+ (NSString *)defaultsKey {
	return kYFFontDefaultsKey;
}


+ (NSDictionary *)valueMap {
	static NSDictionary *map = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if ([self supportsAvenir]) {
			map = [[NSDictionary alloc] initWithObjectsAndKeys:
				   @"Gotham", kYFFontGothamKey,
				   @"Helvetica Neue", kYFFontHelveticaNeueKey,
				   @"Hoefler", kYFFontHoeflerKey,
				   @"Avenir", kYFFontAvenirKey,
				   nil];
		} else {
			map = [[NSDictionary alloc] initWithObjectsAndKeys:
				   @"Gotham", kYFFontGothamKey,
				   @"Helvetica Neue", kYFFontHelveticaNeueKey,
				   @"Hoefler", kYFFontHoeflerKey,
				   nil];
		}
	});
	return map;
}

- (NSArray *)keys {
	if ([[self class] supportsAvenir]) {
		return [[NSArray alloc] initWithObjects:kYFFontGothamKey, kYFFontHelveticaNeueKey, kYFFontHoeflerKey, kYFFontAvenirKey, nil];
	}
	
	return [[NSArray alloc] initWithObjects:kYFFontGothamKey, kYFFontHelveticaNeueKey, kYFFontHoeflerKey, nil];
}


+ (BOOL)supportsAvenir {
	NSComparisonResult result = [[[UIDevice currentDevice] systemVersion] compareToVersionString:@"6.0"];
	return result == NSOrderedDescending || result == NSOrderedSame;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Font";
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
	NSString *key = [[self keys] objectAtIndex:indexPath.row];
	cell.textLabel.font = [UIFont railsSaasFontOfSize:18.0f fontKey:key];
	
	return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
// TODO:	[[NSNotificationCenter defaultCenter] postNotificationName:kYFFontDidChangeNotificationName object:nil];
}

@end
