//
//  YFSettingsTextSizePickerViewController.m
//  rails-saas-ios
//
//  Created by Chris Richards on 04/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFSettingsTextSizePickerViewController.h"
#import "UIFont+RailsSaasiOSAdditions.h"
#import "UIColor+RailsSaasiOSAdditions.h"

NSString *const kYFTextSizeDefaultsKey = @"YFTextSize";
NSString *const kYFTextSizeLargeKey = @"large";
NSString *const kYFTextSizeMediumKey = @"medium";
NSString *const kYFTextSizeSmallKey = @"small";

@implementation YFSettingsTextSizePickerViewController

#pragma mark - Class Methods


+ (CGFloat)fontSizeAdjustment {
	NSString *key = [self selectedKey];
	if ([key isEqualToString:kYFTextSizeSmallKey]) {
		return -3.0f;
	} if ([key isEqualToString:kYFTextSizeLargeKey]) {
		return 4.0f;
	}
	return 0.0f;
}


+ (NSString *)defaultsKey {
	return kYFTextSizeDefaultsKey;
}


+ (NSDictionary *)valueMap {
	static NSDictionary *map = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		map = @{
          kYFTextSizeSmallKey: @"Small",
          kYFTextSizeMediumKey: @"Medium",
          kYFTextSizeLargeKey: @"Large"
          };
	});
	return map;
}

- (NSArray *)keys {
	return @[kYFTextSizeSmallKey, kYFTextSizeMediumKey, kYFTextSizeLargeKey];
}


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Text Size";
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
	cell.textLabel.font = [UIFont railsSaasInterfaceFontOfSize:18.0f];
	cell.textLabel.textColor = [UIColor railsSaasTextColor];
    
	return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
// TODO:	[[NSNotificationCenter defaultCenter] postNotificationName:kYFFontDidChangeNotificationName object:nil];
}

@end
