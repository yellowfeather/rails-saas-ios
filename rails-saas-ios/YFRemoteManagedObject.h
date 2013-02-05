//
//  YFRemoteManagedObject.h
//  rails-saas-ios
//
//  Created by Chris Richards on 05/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "SSDataKit.h"

@class AFJSONRequestOperation;

@interface YFRemoteManagedObject : SSRemoteManagedObject

- (void)create;
- (void)createWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure;

- (void)update;
- (void)updateWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure;

+ (void)sortWithObjects:(NSArray *)objects;
+ (void)sortWithObjects:(NSArray *)objects success:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure;

@end
