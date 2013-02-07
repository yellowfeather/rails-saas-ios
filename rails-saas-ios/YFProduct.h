//
//  YFProduct.h
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

@interface YFProduct : NSManagedObject

@property (strong) NSNumber *productId;
@property (strong) NSString *name;
@property (strong) NSString *desc;
@property (strong) NSString *identifier;
@property (strong) NSNumber *quantity;

- (void)unpackDictionary:(NSDictionary *)dictionary;

@end
