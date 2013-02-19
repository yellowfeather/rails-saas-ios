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

- (void)updateWithDictionaryRepresentation:(NSDictionary *)dictionary
{
    self.productId = [dictionary objectForKey:@"id"];
    self.syncId = [dictionary objectForKey:@"sync_id"];
    self.name = [dictionary objectForKey:@"name"];
    self.desc = [dictionary objectForKey:@"description"];
    self.identifier = [dictionary objectForKey:@"identifier"];
    self.quantity = [dictionary objectForKey:@"quantity"];
    self.createdAt = [NSDate dateFromISO8601String:[dictionary objectForKey:@"created_at"]];
    self.updatedAt = [NSDate dateFromISO8601String:[dictionary objectForKey:@"updated_at"]];
}

@end
