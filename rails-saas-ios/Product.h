//
//  Product.h
//  rails-saas-ios
//
//  Created by Chris Richards on 14/02/2013.
//  Copyright (c) 2013 Yellow Feather Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Product : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * productId;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSString * syncId;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;

@end
