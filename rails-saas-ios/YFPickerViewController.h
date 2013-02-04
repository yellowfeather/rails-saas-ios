//
//  YFPickerViewController.h
//  rails-saas-ios
//
//  Created by Chris Richards on 04/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFGroupedTableViewController.h"

@interface YFPickerViewController : YFGroupedTableViewController

@property (nonatomic, strong) NSIndexPath *currentIndexPath;

+ (NSString *)defaultsKey;
+ (NSString *)selectedKey;
+ (void)setSelectedKey:(NSString *)key;
+ (NSDictionary *)valueMap;
+ (NSString *)textForKey:(NSString *)key;
+ (NSString *)textForSelectedKey;

- (NSArray *)keys;
- (NSString *)cellTextForKey:(id)key;
- (UIImage *)cellImageForKey:(id)key;

@end
