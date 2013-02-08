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

+ (YFSyncManager *)shared {
    static YFSyncManager *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [YFSyncManager alloc];
    });
    
    return _shared;
}

- (void)syncProductsWithBlock:(YFSyncManagerCompletionBlock)completion
{
    YFRailsSaasApiClient *client = [YFRailsSaasApiClient sharedClient];
	if ([client isSignInRequired]) {
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
                    product.name = [dictionary objectForKey:@"name"];
                    product.desc = [dictionary objectForKey:@"description"];
                    product.identifier = [dictionary objectForKey:@"identifier"];
                    product.quantity = [dictionary objectForKey:@"quantity"];
                }
                else {
                    NSLog(@"Skip product: %@", productId);
                }
            }
		}
        completion:^(BOOL success, NSError *error) {
            // note: success will be NO if no changes have been saved
            
            if (error) {
                NSLog(@"Error %@", error);
            }
        }];
	} failure:^(AFJSONRequestOperation *operation, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[SSRateLimit resetLimitForName:@"refresh-products"];
		});
	}];
}

@end
