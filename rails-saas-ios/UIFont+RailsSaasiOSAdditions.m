//
//  UIFont+RailsSaasiOSAdditions.m
//  rails-saas-ios
//
//  Created by Chris Richards on 04/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "UIFont+RailsSaasiOSAdditions.h"
#import "YFSettingsFontPickerViewController.h"
#import "YFSettingsTextSizePickerViewController.h"

NSString *const kYFFontRegularKey = @"Regular";
NSString *const kYFFontItalicKey = @"Italic";
NSString *const kYFFontBoldKey = @"Bold";
NSString *const kYFFontBoldItalicKey = @"BoldItalic";

@implementation UIFont (railsSaasiOSAdditions)

#pragma mark - Font Names

+ (NSDictionary *)railsSaasFontMapForFontKey:(NSString *)key {
	static NSDictionary *fontDictionary = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		fontDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
						  [[NSDictionary alloc] initWithObjectsAndKeys:
						   kYFRegularFontName, kYFFontRegularKey,
						   kYFItalicFontName, kYFFontItalicKey,
						   kYFBoldFontName, kYFFontBoldKey,
						   kYFBoldItalicFontName, kYFFontBoldItalicKey,
						   nil], kYFFontGothamKey,
						  [[NSDictionary alloc] initWithObjectsAndKeys:
						   @"HelveticaNeue", kYFFontRegularKey,
						   @"HelveticaNeue-Italic", kYFFontItalicKey,
						   @"HelveticaNeue-Bold", kYFFontBoldKey,
						   @"HelveticaNeue-BoldItalic", kYFFontBoldItalicKey,
						   nil], kYFFontHelveticaNeueKey,
						  [[NSDictionary alloc] initWithObjectsAndKeys:
						   @"HoeflerText-Regular", kYFFontRegularKey,
						   @"HoeflerText-Italic", kYFFontItalicKey,
						   @"HoeflerText-Black", kYFFontBoldKey,
						   @"HoeflerText-BlackItalic", kYFFontBoldItalicKey,
						   nil], kYFFontHoeflerKey,
						  [[NSDictionary alloc] initWithObjectsAndKeys:
						   @"Avenir-Book", kYFFontRegularKey,
						   @"Avenir-BookOblique", kYFFontItalicKey,
						   @"Avenir-Black", kYFFontBoldKey,
						   @"Avenir-BlackOblique", kYFFontBoldItalicKey,
						   nil], kYFFontAvenirKey,
						  nil];
	});
	return [fontDictionary objectForKey:key];
}


+ (NSString *)railsSaasFontNameForFontKey:(NSString *)key style:(NSString *)style {
	return [[self railsSaasFontMapForFontKey:key] objectForKey:style];
}


+ (NSString *)railsSaasFontNameForStyle:(NSString *)style {
	return [self railsSaasFontNameForFontKey:[YFSettingsFontPickerViewController selectedKey] style:style];
}


#pragma mark - Fonts

+ (UIFont *)railsSaasFontOfSize:(CGFloat)fontSize fontKey:(NSString *)key {
	NSString *fontName = [self railsSaasFontNameForFontKey:key style:kYFFontRegularKey];
	return [self fontWithName:fontName size:fontSize];
}


+ (UIFont *)italicrailsSaasFontOfSize:(CGFloat)fontSize fontKey:(NSString *)key {
	NSString *fontName = [self railsSaasFontNameForFontKey:key style:kYFFontItalicKey];
	return [self fontWithName:fontName size:fontSize];
}


+ (UIFont *)boldrailsSaasFontOfSize:(CGFloat)fontSize fontKey:(NSString *)key {
	NSString *fontName = [self railsSaasFontNameForFontKey:key style:kYFFontBoldKey];
	return [self fontWithName:fontName size:fontSize];
}


+ (UIFont *)boldItalicrailsSaasFontOfSize:(CGFloat)fontSize fontKey:(NSString *)key {
	NSString *fontName = [self railsSaasFontNameForFontKey:key style:kYFFontBoldItalicKey];
	return [self fontWithName:fontName size:fontSize];
}


#pragma mark - Standard

+ (UIFont *)railsSaasFontOfSize:(CGFloat)fontSize {
	fontSize += [YFSettingsTextSizePickerViewController fontSizeAdjustment];
	return [self railsSaasFontOfSize:fontSize fontKey:[YFSettingsFontPickerViewController selectedKey]];
}


+ (UIFont *)italicrailsSaasFontOfSize:(CGFloat)fontSize {
	fontSize += [YFSettingsTextSizePickerViewController fontSizeAdjustment];
	return [self italicrailsSaasFontOfSize:fontSize fontKey:[YFSettingsFontPickerViewController selectedKey]];
}


+ (UIFont *)boldrailsSaasFontOfSize:(CGFloat)fontSize {
	fontSize += [YFSettingsTextSizePickerViewController fontSizeAdjustment];
	return [self boldrailsSaasFontOfSize:fontSize fontKey:[YFSettingsFontPickerViewController selectedKey]];
}


+ (UIFont *)boldItalicrailsSaasFontOfSize:(CGFloat)fontSize {
	fontSize += [YFSettingsTextSizePickerViewController fontSizeAdjustment];
	return [self boldItalicrailsSaasFontOfSize:fontSize fontKey:[YFSettingsFontPickerViewController selectedKey]];
}


#pragma mark - Interface

+ (UIFont *)railsSaasInterfaceFontOfSize:(CGFloat)fontSize {
	return [self fontWithName:kYFRegularFontName size:fontSize];
}


+ (UIFont *)boldrailsSaasInterfaceFontOfSize:(CGFloat)fontSize {
	return [self fontWithName:kYFBoldFontName size:fontSize];
}

@end
