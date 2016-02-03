//
//  PropTemplateEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/28/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectProps.h"

@class PropLayoutEntity, PropTypeEntity;

@interface PropTemplateEntity : PHObjectProps

@property (nonatomic, retain) NSString * font;
@property (nonatomic, retain) NSString * size;
@property (nonatomic, retain) NSString * id_template;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) PropTypeEntity *propType;
@property (nonatomic, retain) NSSet *layouts;
@end

@interface PropTemplateEntity (CoreDataGeneratedAccessors)

- (void)addLayoutsObject:(PropLayoutEntity *)value;
- (void)removeLayoutsObject:(PropLayoutEntity *)value;
- (void)addLayouts:(NSSet *)values;
- (void)removeLayouts:(NSSet *)values;

@end
