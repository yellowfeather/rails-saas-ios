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

- (void)getProductsWithBlock:(YFSyncManagerCompletionBlock)block;
- (void)createProductWithBlock:(Product *)product block:(YFSyncManagerCompletionBlock)block;
- (void)updateProductWithBlock:(Product *)product block:(YFSyncManagerCompletionBlock)block;
- (void)deleteProductWithBlock:(Product *)product block:(YFSyncManagerCompletionBlock)block;

@end
