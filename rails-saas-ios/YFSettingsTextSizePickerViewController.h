//
//  YFSettingsTextSizePickerViewController.h
//  rails-saas-ios
//
//  Created by Chris Richards on 04/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFPickerViewController.h"

extern NSString *const kCDITextSizeDefaultsKey;
extern NSString *const kCDITextSizeLargeKey;
extern NSString *const kCDITextSizeMediumKey;
extern NSString *const kCDITextSizeSmallKey;

@interface YFSettingsTextSizePickerViewController : YFPickerViewController

+ (CGFloat)fontSizeAdjustment;

@end
