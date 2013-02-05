//
//  YFLoadingView.m
//  rails-saas-ios
//
//  Created by Chris Richards on 04/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFLoadingView.h"
#import "UIFont+RailsSaasiOSAdditions.h"
#import "UIColor+RailsSaasiOSAdditions.h"

@implementation YFLoadingView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.textLabel.font = [UIFont railsSaasInterfaceFontOfSize:16.0f];
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

@end
