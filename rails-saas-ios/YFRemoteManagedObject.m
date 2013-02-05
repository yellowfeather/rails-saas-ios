//
//  YFRemoteManagedObject.m
//  rails-saas-ios
//
//  Created by Chris Richards on 05/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFRemoteManagedObject.h"

@implementation YFRemoteManagedObject

- (void)create {
	[self createWithSuccess:nil failure:nil];
}


- (void)createWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure {
	// Subclasses must override this method
}


- (void)update {
	[self updateWithSuccess:nil failure:nil];
}


- (void)updateWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure {
	// Subclasses must override this method
}


+ (void)sortWithObjects:(NSArray *)objects {
	[self sortWithObjects:objects success:nil failure:nil];
}


+ (void)sortWithObjects:(NSArray *)objects success:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure {
	// Subclasses must override this method
}

@end
