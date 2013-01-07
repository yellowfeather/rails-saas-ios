//
//  YFProduct.h
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YFProduct : NSObject

@property (readonly, assign) NSUInteger productId;
@property (readonly, strong) NSString *name;
@property (readonly, strong) NSString *description;
@property (readonly, strong) NSString *identifier;
@property (readonly, assign) NSUInteger quantity;

- (id)initWithAttributes:(NSDictionary *)attributes;

@end
