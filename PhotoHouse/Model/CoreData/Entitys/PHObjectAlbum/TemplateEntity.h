//
//  TemplateEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/27/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectAlbum.h"

@class LayoutEntity;

@interface TemplateEntity : PHObjectAlbum

@property (nonatomic, retain) NSString * font;
@property (nonatomic, retain) NSString * id_template;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * processInsert;
@property (nonatomic, retain) NSString * size;
@property (nonatomic, retain) NSNumber * userTemplate;
@property (nonatomic, retain) NSSet *layouts;
@end

@interface TemplateEntity (CoreDataGeneratedAccessors)

- (void)addLayoutsObject:(LayoutEntity *)value;
- (void)removeLayoutsObject:(LayoutEntity *)value;
- (void)addLayouts:(NSSet *)values;
- (void)removeLayouts:(NSSet *)values;

@end
