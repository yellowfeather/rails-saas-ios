//
//  YFProduct.m
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFProduct.h"

@implementation YFProduct

@synthesize productId;
@synthesize name;
@synthesize desc;
@synthesize identifier;
@synthesize quantity;

- (void)unpackDictionary:(NSDictionary *)dictionary {
	self.productId = [dictionary objectForKey:@"id"];
	self.name = [dictionary objectForKey:@"name"];
	self.desc = [dictionary objectForKey:@"description"];
	self.identifier = [dictionary objectForKey:@"identifier"];
	self.quantity = [dictionary objectForKey:@"quantity"];
}

//#pragma mark - SSManagedObject
//
//+ (NSString *)entityName {
//	return @"Product";
//}
//
//+ (NSArray *)defaultSortDescriptors {
//	return [NSArray arrayWithObjects:
//			[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],
//			nil];
//}
//
//
//#pragma mark - SSRemoteManagedObject
//
//- (void)unpackDictionary:(NSDictionary *)dictionary {
//	self.productId = [dictionary objectForKey:@"id"];
//	self.name = [dictionary objectForKey:@"name"];
//	self.desc = [dictionary objectForKey:@"description"];
//	self.identifier = [dictionary objectForKey:@"identifier"];
//	self.quantity = [dictionary objectForKey:@"quantity"];
//}
//
//
//- (BOOL)shouldUnpackDictionary:(NSDictionary *)dictionary {
//	return YES;
//}
//
//
//#pragma mark - YFRemoteManagedObject
//
//- (void)createWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure {
//	[[YFRailsSaasApiClient sharedClient] createProduct:self success:^(AFJSONRequestOperation *operation, id responseObject) {
//		if (success) {
//			success();
//		}
//	} failure:^(AFJSONRequestOperation *operation, NSError *error) {
//		if (failure) {
//			failure(operation, error);
//		}
//	}];
//}
//
//
//- (void)updateWithSuccess:(void(^)(void))success failure:(void(^)(AFJSONRequestOperation *remoteOperation, NSError *error))failure {
//	[[YFRailsSaasApiClient sharedClient] updateProduct:self success:^(AFJSONRequestOperation *operation, id responseObject) {
//		if (success) {
//			success();
//		}
//	} failure:^(AFJSONRequestOperation *operation, NSError *error) {
//		if (failure) {
//			failure(operation, error);
//		}
//	}];
//}

@end
