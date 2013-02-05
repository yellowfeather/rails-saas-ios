//
//  YFSettingsTextSizePickerViewController.h
//  rails-saas-ios
//
//  Created by Chris Richards on 04/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFPickerViewController.h"

extern NSString *const kYFTextSizeDefaultsKey;
extern NSString *const kYFTextSizeLargeKey;
extern NSString *const kYFTextSizeMediumKey;
extern NSString *const kYFTextSizeSmallKey;

@interface YFSettingsTextSizePickerViewController : YFPickerViewController

+ (CGFloat)fontSizeAdjustment;

@end
