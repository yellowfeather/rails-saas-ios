//
//  YFSyncManager.h
//  rails-saas-ios
//
//  Created by Chris Richards on 08/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^YFSyncManagerCompletionBlock)(BOOL success, NSError *error);


@interface YFSyncManager : NSObject

+ (YFSyncManager *)shared;

- (void)syncProductsWithBlock:(YFSyncManagerCompletionBlock)completion;

@end
