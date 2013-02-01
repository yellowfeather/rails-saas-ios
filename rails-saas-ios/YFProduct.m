//
//  YFProduct.m
//  rails-saas-ios
//
//  Created by Chris Richards on 07/01/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import "YFProduct.h"

@implementation YFProduct

@dynamic productId;
@dynamic name;
@dynamic desc;
@dynamic identifier;
@dynamic quantity;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    [self updateWithAttributes:attributes];
    
    return self;
}

- (void)updateWithAttributes:(NSDictionary *)attributes {
    
    [self setValue:[attributes valueForKeyPath:@"id"] forKey:@"productId"];
    [self setValue:[attributes valueForKeyPath:@"name"] forKey:@"name"];
    [self setValue:[attributes valueForKeyPath:@"description"] forKey:@"desc"];
    [self setValue:[attributes valueForKeyPath:@"identifier"] forKey:@"identifier"];
    [self setValue:[attributes valueForKeyPath:@"quantity"] forKey:@"quantity"];
    
//    NSEntityDescription *entity = [self entity];
//    NSArray *attKeys = [[entity attributesByName] allKeys];
//    NSDictionary *atttributesDict = [attributes dictionaryWithValuesForKeys:attKeys];
//    [self setValuesForKeysWithDictionary:atttributesDict];
}

@end
