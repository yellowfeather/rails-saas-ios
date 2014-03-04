//
//  YFRailsSaasAuthApiClient.h
//  rails-saas-ios
//
//  Created by Chris Richards on 03/03/2014.
//  Copyright (c) 2014 Yellow Feather Ltd. All rights reserved.
//

#import "AFOAuth2Client.h"

@interface YFRailsSaasAuthApiClient : AFOAuth2Client

+ (YFRailsSaasAuthApiClient *)sharedClient;

- (void)signInWithUsernameAndPassword:(NSString *)username
                             password:(NSString *)password
                              success:(void (^)(AFOAuthCredential *credential))success
                              failure:(void (^)(NSError *error))failure;

- (void)refreshTokenWithSuccess:(void (^)(AFOAuthCredential *newCredential))success
                        failure:(void (^)(NSError *error))failure;

- (void)signOut;

- (bool)isSignInRequired;

@end
