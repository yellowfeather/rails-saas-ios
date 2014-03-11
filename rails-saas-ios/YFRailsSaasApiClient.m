//
//  YFRailsSaasApiClient.m
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "AFNetworking.h"
#import "AFOAuth2RequestSerializer.h"
#import "Product.h"
#import "YFRailsSaasApiClient.h"
#import "YFRailsSaasAuthApiClient.h"

typedef void (^YFRailsSaasApiClientRetryBlock)(NSURLSessionDataTask *task, NSError *error);
typedef NSURLSessionDataTask *(^YFRailsSaasApiClientCreateTask)(YFRailsSaasApiClientRetryBlock retryBlock);

static NSString * const kClientBaseURL  = @"http://cheese.rails-saas.com/";
static const int kRetryCount = 3;

@implementation YFRailsSaasApiClient

+ (YFRailsSaasApiClient *)sharedClient {
    static YFRailsSaasApiClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [NSURL URLWithString:kClientBaseURL];
        _sharedClient = [[YFRailsSaasApiClient alloc]initWithBaseURL:url];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    AFOAuthCredential *credential = [[YFRailsSaasAuthApiClient sharedClient] retrieveCredential];
    self.requestSerializer = [AFOAuth2RequestSerializer serializerWithCredential:credential];
    
    return self;
}

- (void)updateCredential:(AFOAuthCredential *)credential
{    
    AFOAuth2RequestSerializer *serializer = (AFOAuth2RequestSerializer *)self.requestSerializer;
    serializer.credential = credential;
}

- (void)refreshAccessToken:(YFRailsSaasApiClientCreateTask)createTaskBlock failure:(YFRailsSaasApiClientFailure)failure retryCount:(int)retryCount
{
    YFRailsSaasAuthApiClient *oauthClient = [YFRailsSaasAuthApiClient sharedClient];
    [oauthClient refreshTokenWithSuccess:^(AFOAuthCredential *newCredential) {
        NSLog(@"[YFRailsSaasApiClient taskWithRetry]: refreshed access token");
        [self updateCredential:newCredential];
        [self taskWithRetry:createTaskBlock failure:failure retryCount:retryCount];
    } failure:^(NSError *error) {
        NSLog(@"[YFRailsSaasApiClient taskWithRetry]: failed to refresh access token");
        if (failure) {
            failure(nil, error);
        }
    }];
}

- (void)taskWithRetry:(YFRailsSaasApiClientCreateTask)createTaskBlock failure:(YFRailsSaasApiClientFailure)failure retryCount:(int)retryCount
{
    YFRailsSaasApiClientFailure retryBlock = ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"[YFRailsSaasApiClient taskWithRetry] failure: retryCount: %d", retryCount);
        
        if (retryCount > 0) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            if (httpResponse.statusCode == 401) {
                NSLog(@"[YFRailsSaasApiClient taskWithRetry]: 401 unauthorised");
                [self refreshAccessToken:createTaskBlock failure:failure retryCount:retryCount - 1];
            }
            else {
                NSLog(@"[YFRailsSaasApiClient taskWithRetry]: retrying");
                [self taskWithRetry:createTaskBlock failure:failure retryCount:retryCount - 1];
            }
        }
        else {
            NSLog(@"[YFRailsSaasApiClient taskWithRetry]: failed");
            if (failure) {
                failure(task, error);
            }
        }
    };
    
    AFOAuth2RequestSerializer *serializer = (AFOAuth2RequestSerializer *)self.requestSerializer;
    if (serializer.credential.isExpired) {
        NSLog(@"[YFRailsSaasApiClient taskWithRetry]: access token has expired");
        [self refreshAccessToken:createTaskBlock failure:failure retryCount:retryCount];
    }
    else {
        createTaskBlock(retryBlock);
    }
}

- (void)sync:(NSDictionary *)params success:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure
{
    NSLog(@"[YFRailsSaasApiClient sync]");
    
    YFRailsSaasApiClientCreateTask createTaskBlock = ^NSURLSessionDataTask *(YFRailsSaasApiClientRetryBlock retryBlock) {
        NSURLSessionDataTask *createdTask = [self GET:@"api/1/sync" parameters:params
                                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                                  NSLog(@"[YFRailsSaasApiClient sync]: success");
                                                  if (success) {
                                                      success(task, responseObject);
                                                  }
                                              }
                                              failure:retryBlock];
        return createdTask;
    };
    
    YFRailsSaasApiClientFailure failureBlock = ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"[YFRailsSaasApiClient sync]: error %@", error);
        if (failure) {
            failure(task, error);
        }
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)getProductsWithSuccess:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure {
    NSLog(@"[YFRailsSaasApiClient getProductsWithSuccess]");

    YFRailsSaasApiClientCreateTask createTaskBlock = ^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *task, NSError *error)) {
        NSURLSessionDataTask *createdTask = [self GET:@"api/1/products" parameters:nil
                                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                                  NSLog(@"getProductsWithSuccess: success");
                                                  if (success) {
                                                      success(task, responseObject);
                                                  }
                                              }
                                              failure:retryBlock];
        return createdTask;
    };
    
    YFRailsSaasApiClientFailure failureBlock = ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"[YFRailsSaasApiClient getProductsWithSuccess]: error %@", error);
        if (failure) {
            failure(task, error);
        }
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)createProduct:(Product *)product success:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure
{
    NSLog(@"[YFRailsSaasApiClient createProduct]");
    
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							product.identifier, @"product[identifier]",
							product.name, @"product[name]",
							product.desc, @"product[description]",
							product.quantity, @"product[quantity]",
							nil];
    
    YFRailsSaasApiClientCreateTask createTaskBlock = ^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *task, NSError *error)) {
        NSURLSessionDataTask *createdTask = [self POST:@"api/1/products" parameters:params
                                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                                  NSLog(@"createProduct: success");
                                                  
                                                  [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                                      NSDictionary *dictionary = [responseObject valueForKeyPath:@"response"];
                                                      Product *updatedProduct = (Product *)[localContext existingObjectWithID:product.objectID error:nil];
                                                      updatedProduct.productId = [dictionary objectForKey:@"id"];
                                                  }];
                                                  
                                                  if (success) {
                                                      success(task, responseObject);
                                                  }
                                              }
                                              failure:retryBlock];
        return createdTask;
    };
    
    YFRailsSaasApiClientFailure failureBlock = ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"[YFRailsSaasApiClient createProduct]: error %@", error);
        if (failure) {
            failure(task, error);
        }
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)updateProduct:(Product *)product success:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure
{
    NSLog(@"[YFRailsSaasApiClient updateProduct]");

	NSString *path = [NSString stringWithFormat:@"api/1/products/%@", product.productId];
	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
							product.identifier, @"product[identifier]",
							product.name, @"product[name]",
							product.desc, @"product[description]",
							product.quantity, @"product[quantity]",
							nil];
    
    YFRailsSaasApiClientCreateTask createTaskBlock = ^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *task, NSError *error)) {
        NSURLSessionDataTask *createdTask = [self PUT:path parameters:params
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   NSLog(@"updateProduct: success");
                                                   
                                                   [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                                       NSDictionary *dictionary = [responseObject valueForKeyPath:@"response"];
                                                       Product *updatedProduct = (Product *)[localContext existingObjectWithID:product.objectID error:nil];
                                                       updatedProduct.productId = [dictionary objectForKey:@"id"];
                                                   }];
                                                   
                                                   if (success) {
                                                       success(task, responseObject);
                                                   }
                                               }
                                               failure:retryBlock];
        return createdTask;
    };
    
    YFRailsSaasApiClientFailure failureBlock = ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"[YFRailsSaasApiClient updateProduct]: error %@", error);
        if (failure) {
            failure(task, error);
        }
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

- (void)deleteProduct:(Product *)product success:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure
{
    NSLog(@"[YFRailsSaasApiClient deleteProduct]");

	NSString *path = [NSString stringWithFormat:@"api/1/products/%@", product.productId];

    YFRailsSaasApiClientCreateTask createTaskBlock = ^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *task, NSError *error)) {
        NSURLSessionDataTask *createdTask = [self DELETE:path parameters:nil
                                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                                  NSLog(@"[YFRailsSaasApiClient deleteProduct]: success");
                                                  if (success) {
                                                      success(task, responseObject);
                                                  }
                                              }
                                              failure:retryBlock];
        return createdTask;
    };
    
    YFRailsSaasApiClientFailure failureBlock = ^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"[YFRailsSaasApiClient deleteProduct]: error %@", error);
        if (failure) {
            failure(task, error);
        }
    };
    
    [self taskWithRetry:createTaskBlock failure:failureBlock retryCount:kRetryCount];
}

@end
