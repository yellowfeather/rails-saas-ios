//
//  YFPullToRefreshView.m
//  rails-saas-ios
//
//  Created by Chris Richards on 04/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFPullToRefreshView.h"
#import "YFPullToRefreshContentView.h"

@implementation YFPullToRefreshView

@synthesize bottomBorderColor = _bottomBorderColor;

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor whiteColor];
		self.contentView = [[YFPullToRefreshContentView alloc] initWithFrame:CGRectZero];
		self.bottomBorderColor = [UIColor colorWithWhite:0.92f alpha:1.0f];
	}
	return self;
}


- (void)drawRect:(CGRect)rect {
	[self.bottomBorderColor setFill];
	
	CGSize size = self.bounds.size;
	CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0.0f, size.height - 1.0f, size.width, 1.0f));
}

@end
