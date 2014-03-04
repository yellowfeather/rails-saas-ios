
//
//  YFSyncManager.m
//  rails-saas-ios
//
//  Created by Chris Richards on 08/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFRailsSaasApiClient.h"
#import "YFRailsSaasAuthApiClient.h"
#import "YFSyncManager.h"
#import "Product.h"
#import "Tombstone.h"

@implementation YFSyncManager

@synthesize lastSynced = _lastSynced;
@synthesize syncInProgress;

+ (YFSyncManager *)shared {
    static YFSyncManager *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [YFSyncManager alloc];
    });
    
    return _shared;
}

- (NSDate *)lastSynced
{
    if (_lastSynced == nil) {
        _lastSynced = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSynced"];
    }
    return _lastSynced;
}

- (void)setLastSynced:(NSDate *)lastSynced
{
    _lastSynced = lastSynced;
    [[NSUserDefaults standardUserDefaults] setObject:lastSynced forKey:@"lastSynced"];
}

-(void)syncWithBlock:(YFSyncManagerCompletionBlock)block
{
    syncInProgress = YES;
    
//    YFRailsSaasAuthApiClient *authClient = [YFRailsSaasAuthApiClient sharedClient];
//    [authClient refreshTokenWithSuccess:nil failure:nil];

    YFRailsSaasApiClient *client = [YFRailsSaasApiClient sharedClient];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (self.lastSynced != nil) {
        params[@"last_synced"] = self.lastSynced;
    }

    NSDictionary *created = [self getCreatedEntities];
    if (created != nil) {
        params[@"created"] = created;
    }
    
    params[@"updated"] = [self getUpdatedEntities];
    params[@"deleted"] = [self getDeletedEntities];
    
	[client sync:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *changes = [responseObject valueForKeyPath:@"response"];
        self.lastSynced = [NSDate dateFromISO8601String:[changes valueForKeyPath:@"last_synced"]];

        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [self syncCreatedEntities:localContext entities:[changes valueForKeyPath:@"created"]];
            [localContext save:nil];
            
            [self syncUpdatedEntities:localContext entities:[changes valueForKeyPath:@"updated"]];
            [localContext save:nil];

            [self syncDeletedEntities:localContext entities:[changes valueForKeyPath:@"deleted"]];
            [localContext save:nil];

            [self updateSyncStatus:localContext];
            [self deleteTombstones:localContext];
        }
        completion:^(BOOL success, NSError *error) {
            // note: success will be NO if there no changes to save
            
            if (error) {
                NSLog(@"Error %@", error);
            }
            
            syncInProgress = NO;
            if (block) {
                block(true, nil);
            }
            
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        syncInProgress = NO;
        
        if (error) {
            NSLog(@"Sync error %@", error);
        }
        
        if (block) {
            block(NO, error);
        }
    }];
}

- (NSDictionary *)getCreatedEntities
{
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"syncStatus == %@", @"2"];
    NSNumber *count = [Product numberOfEntitiesWithPredicate:filter];
    if (count == 0) {
        return nil;
    }

    NSMutableArray *jsonProducts = [NSMutableArray array];
    
    NSArray *products = [Product findAllWithPredicate:filter];
    for (Product *p in products) {
        [jsonProducts addObject:[p dictionaryRepresentation]];
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:jsonProducts, @"products", nil];
}

- (NSDictionary *)getUpdatedEntities
{
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"syncStatus == %@", @"3"];
    NSNumber *count = [Product numberOfEntitiesWithPredicate:filter];
    if (count == 0) {
        return nil;
    }

    NSMutableArray *jsonProducts = [NSMutableArray array];
    
    NSArray *products = [Product findAllWithPredicate:filter];
    for (Product *p in products) {
        [jsonProducts addObject:[p dictionaryRepresentation]];
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:jsonProducts, @"products", nil];
}

- (NSArray *)getDeletedEntities
{
    NSNumber *count = [Tombstone numberOfEntities];
    if (count == 0) {
        return nil;
    }

    NSMutableArray *jsonTombstones = [NSMutableArray array];
    
    NSArray *tombstones = [Tombstone findAll];
    for (Tombstone *t in tombstones) {
        [jsonTombstones addObject:[t dictionaryRepresentation]];
    }
    
    return jsonTombstones;
}

- (void)syncCreatedEntities:(NSManagedObjectContext *)context entities:(id)entities
{
    if (entities == [NSNull null]) {
        NSLog(@"No entities to create");
        return;
    }
    
    NSArray *products = [entities valueForKeyPath:@"products"];
    
    for (NSDictionary *dictionary in products) {
        NSString *syncId = dictionary[@"sync_id"];
        Product *product = [Product findFirstByAttribute:@"syncId" withValue:syncId inContext:context];
        if (product == nil) {
            product = [Product createInContext:context];
        }
        
        [product updateWithDictionaryRepresentation:dictionary];
        NSLog(@"Inserting product: %@", product.productId);
    }
}

- (void)syncUpdatedEntities:(NSManagedObjectContext *)context entities:(id)entities
{
    if (entities == [NSNull null]) {
        NSLog(@"No entities to update");
        return;
    }
    
    NSArray *products = [entities valueForKeyPath:@"products"];
    
    for (NSDictionary *dictionary in products) {
        NSNumber *productId = dictionary[@"id"];
        Product *product = [Product findFirstByAttribute:@"productId" withValue:productId inContext:context];
        
        if (product != nil) {
            NSLog(@"Updating product: %@", productId);
            [product updateWithDictionaryRepresentation:dictionary];
        }
        else {
            NSLog(@"Skip update product: %@", productId);
        }
    }
}

- (void)syncDeletedEntities:(NSManagedObjectContext *)context entities:(id)entities
{
    if (entities == [NSNull null]) {
        NSLog(@"No entities to delete");
        return;
    }
    
    NSArray *tombstones = [entities valueForKeyPath:@"tombstones"];
    
    for (NSDictionary *dictionary in tombstones) {
        NSString *klass = dictionary[@"klass"];
        if (![klass isEqualToString:@"product"]) {
            continue;
        }
        
        NSString *syncId = dictionary[@"sync_id"];
        Product *product = [Product findFirstByAttribute:@"syncId" withValue:syncId inContext:context];
        
        if (product != nil) {
            NSLog(@"Deleting product: %@", syncId);
            [product deleteInContext:context];
        }
        else {
            NSLog(@"Skip delete product: %@", syncId);
        }
    }
}

- (void)updateSyncStatus:(NSManagedObjectContext *)context
{
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"syncStatus != %@", @"1"];
    NSArray *products = [Product findAllWithPredicate:filter inContext:context];
    for (Product *p in products) {
        p.syncStatus = RemoteEntitySyncStatusUnmodified;
    }
}

- (void)deleteTombstones:(NSManagedObjectContext *)context
{
    [Tombstone truncateAllInContext:context];
}

@end
