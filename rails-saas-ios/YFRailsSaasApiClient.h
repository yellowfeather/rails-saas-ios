//
//  YFRailsSaasApiClient.h
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "AFNetworking.h"

@class Product;

typedef void (^YFRailsSaasApiClientSuccess)(NSURLSessionDataTask *task, id responseObject);
typedef void (^YFRailsSaasApiClientFailure)(NSURLSessionDataTask *task, NSError *error);
typedef NSURLSessionDataTask *(^YFRailsSaasApiClientCreateTask)(void (^retryBlock)(NSURLSessionDataTask *task, NSError *error));

@interface YFRailsSaasApiClient : AFHTTPSessionManager

+ (YFRailsSaasApiClient *)sharedClient;

- (id)initWithBaseURL:(NSURL *)url;


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

// sync
- (void)sync:(NSDictionary*)params success:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure;

// products
- (void)getProductsWithSuccess:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure;
- (void)createProduct:(Product *)list success:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure;
- (void)updateProduct:(Product *)list success:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure;
- (void)deleteProduct:(Product *)product success:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure;

@end
