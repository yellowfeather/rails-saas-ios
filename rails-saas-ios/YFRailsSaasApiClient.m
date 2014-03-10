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

static NSString * const kClientBaseURL  = @"http://cheese.rails-saas.com/";
static NSString * const kCredentialIdentifier = @"YFCredentialIdentifier";

@implementation YFRailsSaasApiClient

@synthesize managedObjectContext;

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
    
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:kCredentialIdentifier];
    self.requestSerializer = [AFOAuth2RequestSerializer serializerWithCredential:credential];
    
    return self;
}

- (void)sync:(NSDictionary *)params success:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure
{
    NSLog(@"sync");

    [self GET:@"api/1/sync" parameters:params
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSLog(@"sync: success");
          if (success) {
              success(task, responseObject);
          }
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          NSLog(@"sync: failure");
          if (failure) {
              failure(task, error);
          }
      }];
}

- (void)getProductsWithSuccess:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure {
    NSLog(@"getProductsWithSuccess");

    [self GET:@"api/1/products"
       parameters:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
              NSLog(@"getProductsWithSuccess: success");
              if (success) {
                  success(task, responseObject);
              }
          } failure:^(NSURLSessionDataTask *task, NSError *error) {
              NSLog(@"getProductsWithSuccess: failure");
              if (failure) {
                  failure(task, error);
              }
          }];
}

- (void)createProduct:(Product *)product success:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure
{
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							product.identifier, @"product[identifier]",
							product.name, @"product[name]",
							product.desc, @"product[description]",
							product.quantity, @"product[quantity]",
							nil];
    
    [self POST:@"api/1/products" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            NSDictionary *dictionary = [responseObject valueForKeyPath:@"response"];
            Product *updatedProduct = (Product *)[localContext existingObjectWithID:product.objectID error:nil];
            updatedProduct.productId = [dictionary objectForKey:@"id"];
        }];

        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
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
    
    [self PUT:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

- (void)deleteProduct:(Product *)product success:(YFRailsSaasApiClientSuccess)success failure:(YFRailsSaasApiClientFailure)failure
{
	NSString *path = [NSString stringWithFormat:@"api/1/products/%@", product.productId];

    [self DELETE:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

@end
