//
//  YFHUDView.m
//  rails-saas-ios
//
//  Created by Chris Richards on 04/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFHUDView.h"
#import "UIFont+RailsSaasiOSAdditions.h"

@implementation YFHUDView

- (id)initWithTitle:(NSString *)aTitle loading:(BOOL)isLoading {
	if ((self = [super initWithTitle:aTitle loading:isLoading])) {
		self.textLabel.font = [UIFont railsSaasInterfaceFontOfSize:15.0f];
	}
	return self;
}

@end
