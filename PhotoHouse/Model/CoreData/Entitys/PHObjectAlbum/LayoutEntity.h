//
//  LayoutEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/20/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectAlbum.h"

@class LayerImageEntity, TemplateEntity;

@interface LayoutEntity : PHObjectAlbum

@property (nonatomic, retain) NSString * id_layout;
@property (nonatomic, retain) NSString * layoutType;
@property (nonatomic, retain) NSString * template_psd;
@property (nonatomic, retain) NSNumber * pageIndex;
@property (nonatomic, retain) NSSet *layer;
@property (nonatomic, retain) TemplateEntity *templateAlbum;
@end

@interface LayoutEntity (CoreDataGeneratedAccessors)

- (void)addLayerObject:(LayerImageEntity *)value;
- (void)removeLayerObject:(LayerImageEntity *)value;
- (void)addLayer:(NSSet *)values;
- (void)removeLayer:(NSSet *)values;

@end
