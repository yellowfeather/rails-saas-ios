//
//  YFProduct.h
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import <YFRemoteManagedObject.h>

@interface YFProduct : YFRemoteManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSNumber *quantity;

@end
