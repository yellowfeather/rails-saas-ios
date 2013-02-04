//
//  YFRailsSaasApiClient.h
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFOAuth2Client.h"

typedef void (^YFRailsSaasApiClientSuccess)(AFJSONRequestOperation *operation, id responseObject);
typedef void (^YFRailsSaasApiClientFailure)(AFJSONRequestOperation *operation, NSError *error);

@interface YFRailsSaasApiClient : AFOAuth2Client

+ (YFRailsSaasApiClient *)sharedClient;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

/**
 
 */
- (void)authenticateWithUsernameAndPassword:(NSString *)username
                                   password:(NSString *)password
                                    success:(void (^)(AFOAuthCredential *credential))success
                                    failure:(void (^)(NSError *error))failure;

- (void)logout;

/**
 
 */
- (bool)isLoginRequired;

/**
 
 */
- (void)refreshAccessTokenWithSuccess:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure;

/**
 
 */
- (void)getProductsWithSuccess:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure;

@end
