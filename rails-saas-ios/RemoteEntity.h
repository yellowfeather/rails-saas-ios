//
//  RemoteEntity.h
//  rails-saas-ios
//
//  Created by Chris Richards on 17/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef enum RemoteEntitySyncStatusTypeEnum : int16_t {
    RemoteEntitySyncStatusUnmodified = 1,
    RemoteEntitySyncStatusCreated = 2,
    RemoteEntitySyncStatusModified = 3,
    RemoteEntitySyncStatusDeleted = 4
} RemoteEntitySyncStatusType;
    
@interface RemoteEntity : NSManagedObject

@property (nonatomic, retain) NSString * syncId;
@property (nonatomic) RemoteEntitySyncStatusType syncStatus;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;

@end
