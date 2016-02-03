//
//  ShopTemplateEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/29/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectShopCart.h"

@class ShopCartPropsEntity;

@interface ShopTemplateEntity : PHObjectShopCart

@property (nonatomic, retain) NSString * font;
@property (nonatomic, retain) NSString * id_template;
@property (nonatomic, retain) NSString * name_template;
@property (nonatomic, retain) NSString * size_template;
@property (nonatomic, retain) ShopCartPropsEntity *propType;
@property (nonatomic, retain) NSSet *layouts;
@end

@interface ShopTemplateEntity (CoreDataGeneratedAccessors)

- (void)addLayoutsObject:(NSManagedObject *)value;
- (void)removeLayoutsObject:(NSManagedObject *)value;
- (void)addLayouts:(NSSet *)values;
- (void)removeLayouts:(NSSet *)values;

@end
