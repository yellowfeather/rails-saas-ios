//
//  YFRailsSaasApiClient.m
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "AFHTTPRequestOperation.h"
#import "YFRailsSaasApiClient.h"
#import "YFProduct.h"

static NSString * const kClientBaseURL  = @"http://cheese.rails-saas.dev/";
static NSString * const kClientID       = @"eb6250c28c0a691aab3828b79e4b63c65fa16e5f16ae754cde2cf8aacca5bac0";
static NSString * const kClientSecret   = @"74434359b3f676f1807fc50cd320953650780e47bb8e3e9e14a951992962c406";

@implementation YFRailsSaasApiClient

+ (YFRailsSaasApiClient *)sharedClient {
    static YFRailsSaasApiClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [NSURL URLWithString:kClientBaseURL];
        _sharedClient = [YFRailsSaasApiClient clientWithBaseURL:url clientID:kClientID secret:kClientSecret];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
             clientID:(NSString *)clientID
               secret:(NSString *)secret {
    self = [super initWithBaseURL:url clientID:clientID secret:secret];
    if (!self) {
        return nil;
    }
    
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:self.serviceProviderIdentifier];
    if (credential != nil) {
        [self setAuthorizationHeaderWithCredential:credential];
    }
    
    return self;
}

- (void)authenticateWithUsernameAndPassword:(NSString *)username
                                   password:(NSString *)password
                                    success:(void (^)(AFOAuthCredential *credential))success
                                    failure:(void (^)(NSError *error))failure {
    [self authenticateUsingOAuthWithPath:@"oauth/token"
                                username:username
                                password:password
                                   scope:nil
                                 success:^(AFOAuthCredential *credential) {
                                     NSLog(@"Successfully received OAuth credentials %@", credential.accessToken);
                                     
                                     [AFOAuthCredential storeCredential:credential
                                                         withIdentifier:self.serviceProviderIdentifier];
                                     success(credential);
                                 }
                                 failure:^(NSError *error) {
                                     NSLog(@"Error: %@", error);
                                     failure(error);
                                 }];
}

- (BOOL)isLoginRequired {
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:self.serviceProviderIdentifier];
    if (credential == nil) {
        return true;
    }
    
    return credential.isExpired;
}

- (void)refreshAccessToken:(void (^)(void))success
                   failure:(void (^)(NSError *error))failure {
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:self.serviceProviderIdentifier];
    [self authenticateUsingOAuthWithPath:@"oauth/token"
                            refreshToken:credential.refreshToken
                                 success:^(AFOAuthCredential *newCredential) {
                                     NSLog(@"Successfully refreshed OAuth credentials %@", newCredential.accessToken);
                                     [AFOAuthCredential storeCredential:newCredential
                                                         withIdentifier:self.serviceProviderIdentifier];
                                     success();
                                 }
                                 failure:^(NSError *error) {
                                     NSLog(@"Error: %@", error);
                                     failure(error);
                                 }];
}

- (void)ensureValidAccessToken:(void (^)(void))success {
    if (self.isLoginRequired) {
        [self refreshAccessToken:success
         failure:^(NSError *error) {
             NSLog(@"Error: %@", error);
         }];
    }
    else {
        success();
    }
}

- (void)getProductsWithBlock:(void (^)(NSArray *products, NSError *error))block {
    void (^work)(void) = ^(void) {
        [self getPath:@"api/1/products"
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, id json) {
                  NSLog(@"getProductsWithBlock: success");
                  NSArray *productsFromResponse = [json valueForKeyPath:@"response"];
                  
                  NSMutableArray *mutableProducts = [NSMutableArray arrayWithCapacity:[productsFromResponse count]];
                  for (NSDictionary *attributes in productsFromResponse) {
                      YFProduct *product = [[YFProduct alloc] initWithAttributes:attributes];
                      [mutableProducts addObject:product];
                  }
                  
                  if (block) {
                      block([NSArray arrayWithArray:mutableProducts], nil);
                  }
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Error: %@", error);
                  if (block) {
                      block([NSArray array], error);
                  }
              }];
    };
    
    [self ensureValidAccessToken:work];
}

@end
