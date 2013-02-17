//
//  RemoteEntity.m
//  rails-saas-ios
//
//  Created by Chris Richards on 17/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "NSString+SSToolkitAdditions.h"

#import "RemoteEntity.h"

@implementation RemoteEntity

@dynamic syncId;
@dynamic syncStatus;
@dynamic createdAt;
@dynamic updatedAt;

- (void) awakeFromInsert
{
    [super awakeFromInsert];
    [self setSyncId:[NSString stringWithUUID]];
}

@end
