//
//  YFRailsSaasApiClient.m
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "AFNetworking.h"
#import "AFOAuth2Client.h"
#import "YFRailsSaasApiClient.h"
#import "Product.h"

static NSString * const kClientBaseURL  = @"http://cheese.rails-saas.com/";
static NSString * const kClientID       = @"eb6250c28c0a691aab3828b79e4b63c65fa16e5f16ae754cde2cf8aacca5bac0";
static NSString * const kClientSecret   = @"74434359b3f676f1807fc50cd320953650780e47bb8e3e9e14a951992962c406";

@interface YFRailsSaasApiClient ()
    @property (strong, nonatomic) AFOAuthCredential *credential;
@end

@implementation YFRailsSaasApiClient

@synthesize managedObjectContext;

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

    self.credential = [AFOAuthCredential retrieveCredentialWithIdentifier:self.serviceProviderIdentifier];
    if (self.credential != nil) {
        [self setAuthorizationHeaderWithCredential:self.credential];
    }
    
    return self;
}

#pragma mark - authentication

- (void)signInWithUsernameAndPassword:(NSString *)username
                             password:(NSString *)password
                              success:(void (^)(AFOAuthCredential *credential))success
                              failure:(void (^)(NSError *error))failure {
    [self authenticateUsingOAuthWithPath:@"oauth/token"
                                username:username
                                password:password
                                   scope:nil
                                 success:^(AFOAuthCredential *credential) {
                                     NSLog(@"Successfully received OAuth credentials %@", credential.accessToken);
                                     
                                     self.credential = credential;
                                     [AFOAuthCredential storeCredential:credential
                                                         withIdentifier:self.serviceProviderIdentifier];
                                     success(credential);
                                 }
                                 failure:^(NSError *error) {
                                     NSLog(@"Error: %@", error);
                                     failure(error);
                                 }];
}

- (void)signOut {
    self.credential = nil;
    [AFOAuthCredential deleteCredentialWithIdentifier:self.serviceProviderIdentifier];
}

- (bool)isSignInRequired {
    if (self.credential == nil) {
        return true;
    }
    
    return false;
}

- (void)refreshAccessTokenWithSuccess:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure {
    NSLog(@"refreshAccessTokenWithSuccess");
    
    if (self.credential == nil) {
        if (failure) {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:@"Failed to get credentials" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"world" code:200 userInfo:errorDetail];
            failure(nil, error);
        }
        return;
    }

    if (!self.credential.isExpired) {
        NSLog(@"refreshAccessTokenWithSuccess: credential has not expired");
        
        if (success) {
            success(nil, nil);
        }
        return;
    }

    NSLog(@"refreshAccessTokenWithSuccess: refreshing credential");

    [self authenticateUsingOAuthWithPath:@"oauth/token"
                            refreshToken:self.credential.refreshToken
                                 success:^(AFOAuthCredential *newCredential) {
                                     NSLog(@"Successfully refreshed OAuth credentials %@", newCredential.accessToken);
                                     self.credential = newCredential;
                                     [AFOAuthCredential storeCredential:newCredential
                                                         withIdentifier:self.serviceProviderIdentifier];
                                     
                                     if (success) {
                                         success(nil, nil);
                                     }
                                 }
                                 failure:^(NSError *error) {
                                     NSLog(@"An error occurred refreshing credential: %@", error);
                                     if (failure) {
                                         failure(nil, error);
                                     }
                                 }];
}

- (void)sync:(NSDictionary *)params success:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure
{
    NSLog(@"sync");
    
    YFRailsSaasApiClientSuccess nestedSuccess = ^(AFJSONRequestOperation *operation, id responseObject) {
        [self getPath:@"api/1/sync"
           parameters:params
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"sync: success");
                  if (success) {
                      success((AFJSONRequestOperation *)operation, responseObject);
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"sync: failure");
                  if (failure) {
                      failure((AFJSONRequestOperation *)operation, error);
                  }
              }];
    };
    
    [self refreshAccessTokenWithSuccess:nestedSuccess failure:failure];
}

- (void)getProductsWithSuccess:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure {
    NSLog(@"getProductsWithSuccess");

    YFRailsSaasApiClientSuccess nestedSuccess = ^(AFJSONRequestOperation *operation, id responseObject) {
        [self getPath:@"api/1/products"
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"getProductsWithSuccess: success");
                  if (success) {
                      success((AFJSONRequestOperation *)operation, responseObject);
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"getProductsWithSuccess: failure");
                  if (failure) {
                      failure((AFJSONRequestOperation *)operation, error);
                  }
              }];
    };
    
    [self refreshAccessTokenWithSuccess:nestedSuccess failure:failure];
}

- (void)createProduct:(Product *)product success:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure
{
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							product.identifier, @"product[identifier]",
							product.name, @"product[name]",
							product.desc, @"product[description]",
							product.quantity, @"product[quantity]",
							nil];
    
    YFRailsSaasApiClientSuccess nestedSuccess  = ^(AFJSONRequestOperation *operation, id responseObject) {
        [self postPath:@"api/1/products" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                NSDictionary *dictionary = [responseObject valueForKeyPath:@"response"];
                Product *updatedProduct = (Product *)[localContext existingObjectWithID:product.objectID error:nil];
                updatedProduct.productId = [dictionary objectForKey:@"id"];
            }];

            if (success) {
                success((AFJSONRequestOperation *)operation, responseObject);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failure) {
                failure((AFJSONRequestOperation *)operation, error);
            }
        }];
    };
    
    [self refreshAccessTokenWithSuccess:nestedSuccess failure:failure];
}

- (void)updateProduct:(Product *)product success:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure
{
	NSString *path = [NSString stringWithFormat:@"api/1/products/%@", product.productId];
	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
							product.identifier, @"product[identifier]",
							product.name, @"product[name]",
							product.desc, @"product[description]",
							product.quantity, @"product[quantity]",
							nil];
    YFRailsSaasApiClientSuccess nestedSuccess  = ^(AFJSONRequestOperation *operation, id responseObject) {
        [self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (success) {
                success((AFJSONRequestOperation *)operation, responseObject);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failure) {
                failure((AFJSONRequestOperation *)operation, error);
            }
        }];
    };
    
    [self refreshAccessTokenWithSuccess:nestedSuccess failure:failure];
}

- (void)deleteProduct:(Product *)product success:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure
{
	NSString *path = [NSString stringWithFormat:@"api/1/products/%@", product.productId];
    YFRailsSaasApiClientSuccess nestedSuccess  = ^(AFJSONRequestOperation *operation, id responseObject) {
        [self deletePath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (success) {
                success((AFJSONRequestOperation *)operation, responseObject);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (failure) {
                failure((AFJSONRequestOperation *)operation, error);
            }
        }];
    };
    
    [self refreshAccessTokenWithSuccess:nestedSuccess failure:failure];
}

@end
