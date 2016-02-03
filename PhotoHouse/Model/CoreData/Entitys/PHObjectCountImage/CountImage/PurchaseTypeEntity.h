//
//  PurchaseTypeEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/8/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectStyleEntity.h"

@class StyleTypeEntity;

@interface PurchaseTypeEntity : PHObjectStyleEntity

@property (nonatomic, retain) NSString * id_purchase;
@property (nonatomic, retain) NSSet *styles;
@end

@interface PurchaseTypeEntity (CoreDataGeneratedAccessors)

- (void)addStylesObject:(StyleTypeEntity *)value;
- (void)removeStylesObject:(StyleTypeEntity *)value;
- (void)addStyles:(NSSet *)values;
- (void)removeStyles:(NSSet *)values;

@end
