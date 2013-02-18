//
//  Tombstone.m
//  rails-saas-ios
//
//  Created by Chris Richards on 18/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "Tombstone.h"

@implementation Tombstone

@dynamic klass;
@dynamic syncId;
@dynamic createdAt;

- (NSDictionary *)dictionaryRepresentation
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            self.klass, @"klass",
            self.syncId, @"sync_id",
            self.createdAt, @"created_at",
            nil];
}


@end
