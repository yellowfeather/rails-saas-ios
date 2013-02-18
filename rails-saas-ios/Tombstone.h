//
//  Tombstone.h
//  rails-saas-ios
//
//  Created by Chris Richards on 18/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Tombstone : NSManagedObject

@property (nonatomic, retain) NSString * klass;
@property (nonatomic, retain) NSString * syncId;
@property (nonatomic, retain) NSDate * createdAt;

- (NSDictionary *)dictionaryRepresentation;

@end
