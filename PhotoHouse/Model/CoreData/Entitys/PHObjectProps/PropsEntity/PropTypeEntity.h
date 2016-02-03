//
//  PropTypeEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/28/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectProps.h"

@class PropColorEntity, PropCoverEntity, PropSizeEntity, PropStyleEntity, PropTemplateEntity, PropUturnEntity, StoreEntity;

@interface PropTypeEntity : PHObjectProps

@property (nonatomic, retain) NSString * item_id;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * propName;
@property (nonatomic, retain) NSSet *colors;
@property (nonatomic, retain) NSSet *covers;
@property (nonatomic, retain) NSSet *sizes;
@property (nonatomic, retain) StoreEntity *store;
@property (nonatomic, retain) NSSet *styles;
@property (nonatomic, retain) NSSet *uturns;
@property (nonatomic, retain) NSSet *templates;
@end

@interface PropTypeEntity (CoreDataGeneratedAccessors)

- (void)addColorsObject:(PropColorEntity *)value;
- (void)removeColorsObject:(PropColorEntity *)value;
- (void)addColors:(NSSet *)values;
- (void)removeColors:(NSSet *)values;

- (void)addCoversObject:(PropCoverEntity *)value;
- (void)removeCoversObject:(PropCoverEntity *)value;
- (void)addCovers:(NSSet *)values;
- (void)removeCovers:(NSSet *)values;

- (void)addSizesObject:(PropSizeEntity *)value;
- (void)removeSizesObject:(PropSizeEntity *)value;
- (void)addSizes:(NSSet *)values;
- (void)removeSizes:(NSSet *)values;

- (void)addStylesObject:(PropStyleEntity *)value;
- (void)removeStylesObject:(PropStyleEntity *)value;
- (void)addStyles:(NSSet *)values;
- (void)removeStyles:(NSSet *)values;

- (void)addUturnsObject:(PropUturnEntity *)value;
- (void)removeUturnsObject:(PropUturnEntity *)value;
- (void)addUturns:(NSSet *)values;
- (void)removeUturns:(NSSet *)values;

- (void)addTemplatesObject:(PropTemplateEntity *)value;
- (void)removeTemplatesObject:(PropTemplateEntity *)value;
- (void)addTemplates:(NSSet *)values;
- (void)removeTemplates:(NSSet *)values;

@end
