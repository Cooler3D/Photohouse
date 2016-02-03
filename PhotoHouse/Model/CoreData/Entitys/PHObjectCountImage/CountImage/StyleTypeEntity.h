//
//  StyleTypeEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/8/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectStyleEntity.h"

@class PurchaseTypeEntity, RangeStyleEntity;

@interface StyleTypeEntity : PHObjectStyleEntity

@property (nonatomic, retain) NSString * nameStyleProp;
@property (nonatomic, retain) NSSet *styles;
@property (nonatomic, retain) PurchaseTypeEntity *type;
@end

@interface StyleTypeEntity (CoreDataGeneratedAccessors)

- (void)addStylesObject:(RangeStyleEntity *)value;
- (void)removeStylesObject:(RangeStyleEntity *)value;
- (void)addStyles:(NSSet *)values;
- (void)removeStyles:(NSSet *)values;

@end
