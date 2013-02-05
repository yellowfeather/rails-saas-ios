//
//  YFProductTableViewCell.m
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFProductTableViewCell.h"

@implementation YFProductTableViewCell {
@private
    __weak YFProduct *_product;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    self.textLabel.textColor = [UIColor darkGrayColor];
    self.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
    self.detailTextLabel.numberOfLines = 1;
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return self;
}

- (void)setProduct:(YFProduct *)product {
    _product = product;
    
    self.textLabel.text = _product.name;
    self.detailTextLabel.text = _product.desc;
    self.badgeView.textLabel.text = [_product.quantity stringValue];
    
    if ([_product.quantity intValue] >= 10) {
        self.badgeView.badgeColor = UIColorFromRGB(0xe74019);
    }
    else if ([_product.quantity intValue] >= 5) {
        self.badgeView.badgeColor = UIColorFromRGB(0xf6b003);
    }
    
    [self setNeedsLayout];
}

@end
