//
//  UIColor+RailsSaasiOSAdditions.m
//  rails-saas-ios
//
//  Created by Chris Richards on 04/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "UIColor+RailsSaasiOSAdditions.h"

@implementation UIColor (RailsSaasiOSAdditions)

+ (UIColor *)railsSaasArchesColor {
	return [self colorWithPatternImage:[UIImage imageNamed:@"arches"]];
}


+ (UIColor *)railsSaasTextColor {
	return [self colorWithWhite:0.267f alpha:1.0f];
}


+ (UIColor *)railsSaasLightTextColor {
	return [self colorWithWhite:0.651f alpha:1.0f];
}


+ (UIColor *)railsSaasBlueColor {
	return [self colorWithRed:0.031f green:0.506f blue:0.702f alpha:1.0f];
}


+ (UIColor *)railsSaasSteelColor {
	return [self colorWithRed:0.376f green:0.408f blue:0.463f alpha:1.0f];
}


+ (UIColor *)railsSaasHighlightColor {
	return [self colorWithRed:1.000f green:0.996f blue:0.792f alpha:1.0f];
}


+ (UIColor *)railsSaasOrangeColor {
	return [self colorWithRed:1.000f green:0.447f blue:0.263f alpha:1.0f];
}

@end
