//
//  Product.m
//  rails-saas-ios
//
//  Created by Chris Richards on 14/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "NSString+SSToolkitAdditions.h"
#import "Product.h"


@implementation Product

@dynamic desc;
@dynamic identifier;
@dynamic name;
@dynamic productId;
@dynamic quantity;
@dynamic syncId;
@dynamic createdAt;
@dynamic updatedAt;

- (void) awakeFromInsert
{
    [super awakeFromInsert];
    [self setSyncId:[NSString stringWithUUID]];
}

@end
