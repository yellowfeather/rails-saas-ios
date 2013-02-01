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

static NSString * const kClientBaseURL  = @"http://cheese.rails-saas.com/";
static NSString * const kClientID       = @"eb6250c28c0a691aab3828b79e4b63c65fa16e5f16ae754cde2cf8aacca5bac0";
static NSString * const kClientSecret   = @"74434359b3f676f1807fc50cd320953650780e47bb8e3e9e14a951992962c406";

@implementation YFRailsSaasApiClient {
    dispatch_queue_t _callbackQueue;
}

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
    
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:self.serviceProviderIdentifier];
    if (credential != nil) {
        [self setAuthorizationHeaderWithCredential:credential];
    }

    NSOperationQueue *queue = [self operationQueue];
    [queue setMaxConcurrentOperationCount:1];
    
    // _callbackQueue = dispatch_queue_create("com.rails-saas.network-callback-queue", 0);

    return self;
}

#pragma mark - AFHTTPClient

//- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
//	NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];
//    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
//	return request;
//}
//
//- (void)enqueueHTTPRequestOperation:(AFHTTPRequestOperation *)operation {
//	operation.successCallbackQueue = _callbackQueue;
//	operation.failureCallbackQueue = _callbackQueue;
//	[super enqueueHTTPRequestOperation:operation];
//}

#pragma mark - authentication

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

- (bool)isLoginRequired {
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:self.serviceProviderIdentifier];
    if (credential == nil) {
        return true;
    }
    
    return false;
}


- (void)refreshAccessTokenWithFailure:(YFRailsSaasApiClientFailure)failure {
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:self.serviceProviderIdentifier];
    if (credential == nil) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Failed to get credentials" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"world" code:200 userInfo:errorDetail];
        failure(nil, error);
        return;
    }

    if (!credential.isExpired) {
        return;
    }

    [self authenticateUsingOAuthWithPath:@"oauth/token"
                            refreshToken:credential.refreshToken
                                 success:^(AFOAuthCredential *newCredential) {
                                     NSLog(@"Successfully refreshed OAuth credentials %@", newCredential.accessToken);
                                     [AFOAuthCredential storeCredential:newCredential
                                                         withIdentifier:self.serviceProviderIdentifier];
                                 }
                                 failure:^(NSError *error) {
                                     NSLog(@"Error: %@", error);
                                     failure(nil, error);
                                 }];
}

- (void)getProductsWithSuccess:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure {
    [self refreshAccessTokenWithFailure:failure];

    [self getPath:@"api/1/products"
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"getProductsWithBlock: success");
              NSArray *productsFromResponse = [responseObject valueForKeyPath:@"response"];
              
              YFProduct *productMO = nil;
              for (NSDictionary *attributes in productsFromResponse) {
                  if (attributes) {
                      productMO = [NSEntityDescription insertNewObjectForEntityForName:@"Product"
                                                                inManagedObjectContext:managedObjectContext];
                      
                      [productMO updateWithAttributes:attributes];
                  }
              }

              NSError *error;
              ZAssert([managedObjectContext save:&error], @"Error saving moc: %@\n%@",
                      [error localizedDescription],
                      [error userInfo]);
              
              if (success) {
                  success((AFJSONRequestOperation *)operation, responseObject);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure((AFJSONRequestOperation *)operation, error);
              }
          }];
}

@end
