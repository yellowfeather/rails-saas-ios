//
//  YFProductTableViewCell.h
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFProduct.h"

@interface YFProductTableViewCell : SSBadgeTableViewCell

@property (nonatomic, weak) YFProduct *product;

@end
