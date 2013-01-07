//
//  YFProduct.m
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFProduct.h"

@implementation YFProduct

@synthesize productId = _productId;
@synthesize name = _name;
@synthesize description = _description;
@synthesize identifier = _identifier;
@synthesize quantity = _quantity;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _productId = [[attributes valueForKeyPath:@"id"] integerValue];
    _name = [attributes valueForKeyPath:@"name"];
    _description = [attributes valueForKeyPath:@"description"];
    _identifier = [attributes valueForKeyPath:@"identifier"];
    _quantity = [[attributes valueForKeyPath:@"quantity"] integerValue];
    
    return self;
}

@end
