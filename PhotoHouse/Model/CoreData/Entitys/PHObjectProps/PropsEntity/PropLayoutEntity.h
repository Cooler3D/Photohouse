//
//  PropLayoutEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/8/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectProps.h"

@class PropLayerImageEntity, PropPlaceHolderEntity, PropTemplateEntity;

@interface PropLayoutEntity : PHObjectProps

@property (nonatomic, retain) NSString * id_layout;
@property (nonatomic, retain) NSString * layoutType;
@property (nonatomic, retain) NSString * template_psd;
@property (nonatomic, retain) NSString * noScaleCombined;
@property (nonatomic, retain) NSSet *layer;
@property (nonatomic, retain) PropTemplateEntity *templateAlbum;
@property (nonatomic, retain) PropPlaceHolderEntity *combinedLayer;
@end

@interface PropLayoutEntity (CoreDataGeneratedAccessors)

- (void)addLayerObject:(PropLayerImageEntity *)value;
- (void)removeLayerObject:(PropLayerImageEntity *)value;
- (void)addLayer:(NSSet *)values;
- (void)removeLayer:(NSSet *)values;

@end
