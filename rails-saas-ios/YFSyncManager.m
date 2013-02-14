
//
//  YFSyncManager.m
//  rails-saas-ios
//
//  Created by Chris Richards on 08/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFRailsSaasApiClient.h"
#import "YFSyncManager.h"
#import "Product.h"

@implementation YFSyncManager

@synthesize lastSynced;

+ (YFSyncManager *)shared {
    static YFSyncManager *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [YFSyncManager alloc];
    });
    
    return _shared;
}

-(void)syncWithBlock:(YFSyncManagerCompletionBlock)block
{
    YFRailsSaasApiClient *client = [YFRailsSaasApiClient sharedClient];
	[client getSyncChangeSet:self.lastSynced success:^(AFJSONRequestOperation *operation, id responseObject) {
        NSArray *changes = [responseObject valueForKeyPath:@"response"];
        self.lastSynced = [self parseDate:[changes valueForKeyPath:@"last_synced"]];

        [self syncCreatedEntities:[changes valueForKeyPath:@"created"]];
        [self syncUpdatedEntities:[changes valueForKeyPath:@"updated"]];
        [self syncDeletedEntities:[changes valueForKeyPath:@"deleted"]];
        
        if (block) {
            block(true, nil);
        }

    } failure:^(AFJSONRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SSRateLimit resetLimitForName:@"refresh-products"];
        });
         
        if (block) {
            block(NO, error);
        }
    }];
}

- (void)getProductsWithBlock:(YFSyncManagerCompletionBlock)block
{
    YFRailsSaasApiClient *client = [YFRailsSaasApiClient sharedClient];
	if ([client isSignInRequired]) {
        if (block) {
            block(YES, nil);
        }
		return;
	}
    
	[client getProductsWithSuccess:^(AFJSONRequestOperation *operation, id responseObject) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            NSArray *productsFromResponse = [responseObject valueForKeyPath:@"response"];
            
            for (NSDictionary *dictionary in productsFromResponse) {
                
                NSNumber *productId = dictionary[@"id"];
                Product *product = [Product findFirstByAttribute:@"productId" withValue:productId inContext:localContext];
                
                if (product == nil) {
                    NSLog(@"Inserting product: %@", productId);
                    product = [Product createInContext:localContext];
                    product.productId = [dictionary objectForKey:@"id"];
                    product.syncId = [dictionary objectForKey:@"sync_id"];
                    product.name = [dictionary objectForKey:@"name"];
                    product.desc = [dictionary objectForKey:@"description"];
                    product.identifier = [dictionary objectForKey:@"identifier"];
                    product.quantity = [dictionary objectForKey:@"quantity"];
                    product.createdAt = [self parseDate:[dictionary objectForKey:@"created_at"]];
                    product.updatedAt = [self parseDate:[dictionary objectForKey:@"updated_at"]];
                }
                else {
                    NSLog(@"Skip product: %@", productId);
                }
            }
		}
        completion:^(BOOL success, NSError *error) {
            // note: success will be NO if there no changes to save
            
            if (error) {
                NSLog(@"Error %@", error);
            }
            
            if (block) {
                block(success, error);
            }
        }];
	} failure:^(AFJSONRequestOperation *operation, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[SSRateLimit resetLimitForName:@"refresh-products"];
		});
        
        if (block) {
            block(NO, error);
        }
	}];
}

- (void)createProductWithBlock:(Product *)product block:(YFSyncManagerCompletionBlock)block
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Product *newProduct = [Product createInContext:localContext];
        newProduct.syncId = product.syncId;
        newProduct.identifier = product.identifier;
        newProduct.name = product.name;
        newProduct.desc = product.desc;
        newProduct.quantity = product.quantity;
        newProduct.createdAt = product.createdAt;
        newProduct.updatedAt = product.updatedAt;
        
        [[YFRailsSaasApiClient sharedClient] createProduct:newProduct success:nil failure:nil];
    }
    completion:^(BOOL success, NSError *error) {
        if (block) {
            block(success, error);
        }
    }];
}

- (void)updateProductWithBlock:(Product *)product block:(YFSyncManagerCompletionBlock)block
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Product *existingProduct = (Product *)[localContext existingObjectWithID:product.objectID error:nil];
        existingProduct.syncId = product.syncId;
        existingProduct.identifier = product.identifier;
        existingProduct.name = product.name;
        existingProduct.desc = product.desc;
        existingProduct.quantity = product.quantity;
        existingProduct.createdAt = product.createdAt;
        existingProduct.updatedAt = product.updatedAt;
        
        [[YFRailsSaasApiClient sharedClient] updateProduct:existingProduct success:nil failure:nil];
    }
    completion:^(BOOL success, NSError *error) {
        if (block) {
            block(success, error);
        }
    }];
}

- (void)deleteProductWithBlock:(Product *)product block:(YFSyncManagerCompletionBlock)block
{
    [[YFRailsSaasApiClient sharedClient] deleteProduct:product success:nil failure:nil];
}

- (void)syncCreatedEntities:(id)entities
{
    if (entities == [NSNull null]) {
        NSLog(@"No entities to create");
        return;
    }
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *products = [entities valueForKeyPath:@"products"];
        
        for (NSDictionary *dictionary in products) {
            Product *product = [Product createInContext:localContext];
            product.productId = [dictionary objectForKey:@"id"];
            product.syncId = [dictionary objectForKey:@"sync_id"];
            product.name = [dictionary objectForKey:@"name"];
            product.desc = [dictionary objectForKey:@"description"];
            product.identifier = [dictionary objectForKey:@"identifier"];
            product.quantity = [dictionary objectForKey:@"quantity"];
            product.createdAt = [self parseDate:[dictionary objectForKey:@"created_at"]];
            product.updatedAt = [self parseDate:[dictionary objectForKey:@"updated_at"]];
            NSLog(@"Inserting product: %@", product.productId);
        }
    }
    completion:^(BOOL success, NSError *error) {
        // note: success will be NO if there no changes to save
                          
        if (error) {
            NSLog(@"Error %@", error);
        }
    }];
}

- (void)syncUpdatedEntities:(id)entities
{
    if (entities == [NSNull null]) {
        NSLog(@"No entities to update");
        return;
    }
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *products = [entities valueForKeyPath:@"products"];
        
        for (NSDictionary *dictionary in products) {
            NSNumber *productId = dictionary[@"id"];
            Product *product = [Product findFirstByAttribute:@"productId" withValue:productId inContext:localContext];
            
            if (product != nil) {
                NSLog(@"Updating product: %@", productId);
                product.productId = [dictionary objectForKey:@"id"];
                product.syncId = [dictionary objectForKey:@"sync_id"];
                product.name = [dictionary objectForKey:@"name"];
                product.desc = [dictionary objectForKey:@"description"];
                product.identifier = [dictionary objectForKey:@"identifier"];
                product.quantity = [dictionary objectForKey:@"quantity"];
                product.createdAt = [self parseDate:[dictionary objectForKey:@"created_at"]];
                product.updatedAt = [self parseDate:[dictionary objectForKey:@"updated_at"]];
            }
            else {
                NSLog(@"Skip update product: %@", productId);
            }
        }
    }
    completion:^(BOOL success, NSError *error) {
        // note: success will be NO if there no changes to save
                          
        if (error) {
            NSLog(@"Error %@", error);
        }
    }];
}

- (void)syncDeletedEntities:(id)entities
{
    if (entities == [NSNull null]) {
        NSLog(@"No entities to delete");
        return;
    }
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *tombstones = [entities valueForKeyPath:@"tombstones"];
        
        for (NSDictionary *dictionary in tombstones) {
            NSString *klass = dictionary[@"klass"];
            if (![klass isEqualToString:@"product"]) {
                continue;
            }
            
            NSString *syncId = dictionary[@"sync_id"];
            Product *product = [Product findFirstByAttribute:@"syncId" withValue:syncId inContext:localContext];
            
            if (product != nil) {
                NSLog(@"Deleting product: %@", syncId);
                [product deleteInContext:localContext];
            }
            else {
                NSLog(@"Skip delete product: %@", syncId);
            }
        }
    }
    completion:^(BOOL success, NSError *error) {
        // note: success will be NO if there no changes to save
                          
        if (error) {
            NSLog(@"Error %@", error);
        }
    }];
}

// from https://github.com/soffes/ssdatakit/blob/master/SSDataKit/SSRemoteManagedObject.m
- (NSDate *)parseDate:(id)dateStringOrDateNumber {
	// Return nil if nil is given
	if (!dateStringOrDateNumber || dateStringOrDateNumber == [NSNull null]) {
		return nil;
	}
    
	// Parse number
	if ([dateStringOrDateNumber isKindOfClass:[NSNumber class]]) {
		return [NSDate dateWithTimeIntervalSince1970:[dateStringOrDateNumber doubleValue]];
	}
    
	// Parse string
	else if ([dateStringOrDateNumber isKindOfClass:[NSString class]]) {
		// ISO8601 Parser borrowed from SSToolkit. http://sstoolk.it
		NSString *iso8601 = dateStringOrDateNumber;
		if (!iso8601) {
			return nil;
		}
        
		const char *str = [iso8601 cStringUsingEncoding:NSUTF8StringEncoding];
		char newStr[25];
        
		struct tm tm;
		size_t len = strlen(str);
		if (len == 0) {
			return nil;
		}
        
		// UTC
		if (len == 20 && str[len - 1] == 'Z') {
			strncpy(newStr, str, len - 1);
			strncpy(newStr + len - 1, "+0000", 5);
		}
        
		// Timezone
		else if (len == 24 && str[22] == ':') {
			strncpy(newStr, str, 22);
			strncpy(newStr + 22, str + 23, 2);
		}
        
		// Poorly formatted timezone
		else {
			strncpy(newStr, str, len > 24 ? 24 : len);
		}
        
		// Add null terminator
		newStr[sizeof(newStr) - 1] = 0;
        
		if (strptime(newStr, "%FT%T%z", &tm) == NULL) {
			return nil;
		}
        
		time_t t;
		t = mktime(&tm);
        
		return [NSDate dateWithTimeIntervalSince1970:t];
	}
    
	NSAssert1(NO, @"[YFSyncManager] Failed to parse date: %@", dateStringOrDateNumber);
	return nil;
}

@end
