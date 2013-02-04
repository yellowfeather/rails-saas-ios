//
//  UIFont+RailsSaasiOSAdditions.h
//  rails-saas-ios
//
//  Created by Chris Richards on 04/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIFont+RailsSaasiOSAdditions.h"

extern NSString *const kCDIFontRegularKey;
extern NSString *const kCDIFontItalicKey;
extern NSString *const kCDIFontBoldKey;
extern NSString *const kCDIFontBoldItalicKey;

@interface UIFont (RailsSaasiOSAdditions)

#pragma mark - Font Names

+ (NSDictionary *)railsSaasFontMapForFontKey:(NSString *)key;
+ (NSString *)railsSaasFontNameForFontKey:(NSString *)key style:(NSString *)style;
+ (NSString *)railsSaasFontNameForStyle:(NSString *)style;

#pragma mark - Fonts

+ (UIFont *)railsSaasFontOfSize:(CGFloat)fontSize fontKey:(NSString *)key;
+ (UIFont *)boldrailsSaasFontOfSize:(CGFloat)fontSize fontKey:(NSString *)key;
+ (UIFont *)boldItalicrailsSaasFontOfSize:(CGFloat)fontSize fontKey:(NSString *)key;
+ (UIFont *)italicrailsSaasFontOfSize:(CGFloat)fontSize fontKey:(NSString *)key;


#pragma mark - Standard

+ (UIFont *)railsSaasFontOfSize:(CGFloat)fontSize;
+ (UIFont *)italicrailsSaasFontOfSize:(CGFloat)fontSize;
+ (UIFont *)boldrailsSaasFontOfSize:(CGFloat)fontSize;
+ (UIFont *)boldItalicrailsSaasFontOfSize:(CGFloat)fontSize;


#pragma mark - Interface

+ (UIFont *)railsSaasInterfaceFontOfSize:(CGFloat)fontSize;
+ (UIFont *)boldrailsSaasInterfaceFontOfSize:(CGFloat)fontSize;

@end
