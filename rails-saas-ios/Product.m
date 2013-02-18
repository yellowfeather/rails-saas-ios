//
//  Product.m
//  rails-saas-ios
//
//  Created by Chris Richards on 14/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "Product.h"


@implementation Product

@dynamic desc;
@dynamic identifier;
@dynamic name;
@dynamic productId;
@dynamic quantity;

+ (NSString *)entityName {
	return @"product";
}

- (NSDictionary *)dictionaryRepresentation
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            self.productId, @"id",
            self.identifier, @"identifier",
            self.name, @"name",
            self.desc, @"description",
            self.quantity, @"quantity",
            self.syncId, @"sync_id",
            nil];
}

@end
