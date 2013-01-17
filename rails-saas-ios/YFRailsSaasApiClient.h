//
//  YFRailsSaasApiClient.h
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFOAuth2Client.h"

@interface YFRailsSaasApiClient : AFOAuth2Client

+ (YFRailsSaasApiClient *)sharedClient;

/**
 
 */
- (void)authenticateWithUsernameAndPassword:(NSString *)username
                                   password:(NSString *)password
                                    success:(void (^)(AFOAuthCredential *credential))success
                                    failure:(void (^)(NSError *error))failure;
/**
 
 */
- (void)refreshAccessTokenWithBlock:(void (^)(void))success
                            failure:(void (^)(NSError *error))failure;

/**
 
 */
- (void)getProductsWithBlock:(void (^)(NSArray *products, NSError *error))block;

@end
