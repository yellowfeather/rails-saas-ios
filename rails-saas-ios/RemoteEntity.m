//
//  RemoteEntity.m
//  rails-saas-ios
//
//  Created by Chris Richards on 17/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "NSString+SSToolkitAdditions.h"

#import "RemoteEntity.h"
#import "Tombstone.h"
#import "YFSyncManager.h"

@implementation RemoteEntity

@dynamic syncId;
@dynamic syncStatus;
@dynamic createdAt;
@dynamic updatedAt;

- (void) awakeFromInsert
{
    [super awakeFromInsert];
    
    YFSyncManager *syncManager = [YFSyncManager shared];
    if ([syncManager syncInProgress]) {
        return;
    }

    [self setSyncId:[[NSString stringWithUUID] lowercaseString]];
}

- (void) prepareForDeletion
{
    [super prepareForDeletion];
    
    YFSyncManager *syncManager = [YFSyncManager shared];
    if ([syncManager syncInProgress]) {
        return;
    }
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Tombstone *tombstone = [Tombstone findFirstByAttribute:@"syncId" withValue:self.syncId inContext:localContext];
        if (tombstone == nil) {
            NSLog(@"Tombstoning entity %@ with syncId %@", NSStringFromClass([self class]), self.syncId);
            tombstone = [Tombstone createInContext:localContext];
            tombstone.klass = NSStringFromClass([self class]);
            tombstone.syncId = self.syncId;
            tombstone.createdAt = [NSDate date];
        }
    }];
}

@end
