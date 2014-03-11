//
//  YFRailsSaasAuthApiClient.m
//  rails-saas-ios
//
//  Created by Chris Richards on 03/03/2014.
//  Copyright (c) 2014 Yellow Feather Ltd. All rights reserved.
//

#import "YFRailsSaasApiClient.h"
#import "YFRailsSaasAuthApiClient.h"

static NSString * const kClientBaseURL  = @"http://rails-saas.com/";
static NSString * const kClientID       = @"eb6250c28c0a691aab3828b79e4b63c65fa16e5f16ae754cde2cf8aacca5bac0";
static NSString * const kClientSecret   = @"74434359b3f676f1807fc50cd320953650780e47bb8e3e9e14a951992962c406";

static NSString * const kCredentialIdentifier = @"YFCredentialIdentifier";

@implementation YFRailsSaasAuthApiClient

+ (YFRailsSaasAuthApiClient *)sharedClient {
    static YFRailsSaasAuthApiClient *_sharedClient = nil;
    static dispatch_once_t _onceToken;
    
    dispatch_once(&_onceToken, ^{
        NSURL *url = [NSURL URLWithString:kClientBaseURL];
        _sharedClient = [YFRailsSaasAuthApiClient clientWithBaseURL:url clientID:kClientID secret:kClientSecret];
    });
    
    return _sharedClient;
}

- (void)signInWithUsernameAndPassword:(NSString *)username
                             password:(NSString *)password
                              success:(void (^)(AFOAuthCredential *credential))success
                              failure:(void (^)(NSError *error))failure {
    NSLog(@"[YFRailsSaasAuthApiClient signInWithUsernameAndPassword]");
    
    [self authenticateUsingOAuthWithPath:@"oauth/token"
                                username:username
                                password:password
                                   scope:nil
                                 success:^(AFOAuthCredential *credential) {
                                     NSLog(@"[YFRailsSaasAuthApiClient signInWithUsernameAndPassword]: received access token %@", credential.accessToken);
                                     
                                     [AFOAuthCredential storeCredential:credential withIdentifier:kCredentialIdentifier];
                                     
                                     if (success) {
                                         success(credential);
                                     }
                                 }
                                 failure:^(NSError *error) {
                                     NSLog(@"Error: %@", error);
                                     failure(error);
                                 }];
}

- (void)refreshTokenWithSuccess:(void (^)(AFOAuthCredential *newCredential))success
                        failure:(void (^)(NSError *error))failure
{
    NSLog(@"[YFRailsSaasAuthApiClient refreshTokenWithSuccess]");
    
    AFOAuthCredential *credential = [self retrieveCredential];
    if (credential == nil) {
		NSLog(@"[YFRailsSaasAuthApiClient refreshTokenWithSuccess]: credential is nil");
        if (failure) {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:@"Failed to get credentials" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"world" code:200 userInfo:errorDetail];
            failure(error);
        }
        return;
    }
    
    NSLog(@"[YFRailsSaasAuthApiClient refreshTokenWithSuccess]: refreshing credential, credential.refreshToken: %@", credential.refreshToken);
    
    [self authenticateUsingOAuthWithPath:@"oauth/token"
                            refreshToken:credential.refreshToken
                                 success:^(AFOAuthCredential *newCredential) {
                                     NSLog(@"[YFRailsSaasAuthApiClient refreshTokenWithSuccess]: refreshed access token %@", newCredential.accessToken);
                                     [AFOAuthCredential storeCredential:newCredential withIdentifier:kCredentialIdentifier];

                                     if (success) {
                                         success(newCredential);
                                     }
                                 }
                                 failure:^(NSError *error) {
                                     NSLog(@"[YFRailsSaasAuthApiClient refreshTokenWithSuccess]: an error occurred refreshing credential: %@", error);
                                     if (failure) {
                                         failure(error);
                                     }
                                 }];
}

- (void)signOut {
    [AFOAuthCredential deleteCredentialWithIdentifier:kCredentialIdentifier];
}

- (bool)isSignInRequired {
    AFOAuthCredential *credential = [self retrieveCredential];
    if (credential == nil) {
        return true;
    }
    
    return false;
}

- (AFOAuthCredential *)retrieveCredential
{
    return [AFOAuthCredential retrieveCredentialWithIdentifier:kCredentialIdentifier];
}

@end
