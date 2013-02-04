//
//  YFSettingsFontPickerViewController.h
//  rails-saas-ios
//
//  Created by Chris Richards on 04/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFPickerViewController.h"

extern NSString *const kYFFontDefaultsKey;
extern NSString *const kYFFontGothamKey;
extern NSString *const kYFFontHelveticaNeueKey;
extern NSString *const kYFFontHoeflerKey;
extern NSString *const kYFFontAvenirKey;

@interface YFSettingsFontPickerViewController : YFPickerViewController

+ (BOOL)supportsAvenir;

@end
