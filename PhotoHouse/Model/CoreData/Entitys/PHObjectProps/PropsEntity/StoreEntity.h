//
//  StoreEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/30/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectProps.h"

@class PropTypeEntity;

@interface StoreEntity : PHObjectProps

@property (nonatomic, retain) NSNumber * availability;
@property (nonatomic, retain) NSString * category_id;
@property (nonatomic, retain) NSString * category_name;
@property (nonatomic, retain) NSString * id_puchase;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *propTypes;
@end

@interface StoreEntity (CoreDataGeneratedAccessors)

- (void)addPropTypesObject:(PropTypeEntity *)value;
- (void)removePropTypesObject:(PropTypeEntity *)value;
- (void)addPropTypes:(NSSet *)values;
- (void)removePropTypes:(NSSet *)values;

@end
