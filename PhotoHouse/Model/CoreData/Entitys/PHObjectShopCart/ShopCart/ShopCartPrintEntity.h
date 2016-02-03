//
//  ShopCartPrintEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/5/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectShopCart.h"

@class ShopCartImageEntity, ShopCartPropsEntity;

@interface ShopCartPrintEntity : PHObjectShopCart

@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSString * nameCategory;
@property (nonatomic, retain) NSString * namePurchase;
@property (nonatomic, retain) NSNumber * processInsert;
@property (nonatomic, retain) NSNumber * purchaseID;
@property (nonatomic, retain) NSString * typeName;
@property (nonatomic, retain) NSNumber * unique_print;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) ShopCartPropsEntity *props;
@end

@interface ShopCartPrintEntity (CoreDataGeneratedAccessors)

- (void)addImagesObject:(ShopCartImageEntity *)value;
- (void)removeImagesObject:(ShopCartImageEntity *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
