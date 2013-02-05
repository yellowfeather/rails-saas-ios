//
//  YFPullToRefreshSimpleContentView.m
//  rails-saas-ios
//
//  Created by Chris Richards on 04/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFPullToRefreshContentView.h"
#import "UIColor+RailsSaasiOSAdditions.h"
#import "UIFont+RailsSaasiOSAdditions.h"

@implementation YFPullToRefreshContentView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.statusLabel.font = [UIFont railsSaasInterfaceFontOfSize:15.0f];
		self.statusLabel.textColor = [UIColor railsSaasTextColor];
		self.statusLabel.backgroundColor = [UIColor whiteColor];
	}
	return self;
}

@end
