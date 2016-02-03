//
//  ShopLayoutEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/8/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectShopCart.h"

@class ShopImageLayerEntity, ShopPlaceHolderEntity, ShopTemplateEntity;

@interface ShopLayoutEntity : PHObjectShopCart

@property (nonatomic, retain) NSString * id_layout;
@property (nonatomic, retain) NSString * layoutType;
@property (nonatomic, retain) NSNumber * pageIndex;
@property (nonatomic, retain) NSString * template_psd;
@property (nonatomic, retain) NSString * noScaleCombined;
@property (nonatomic, retain) NSSet *layers;
@property (nonatomic, retain) ShopTemplateEntity *templateAlbum;
@property (nonatomic, retain) ShopPlaceHolderEntity *combinedLayer;
@end

@interface ShopLayoutEntity (CoreDataGeneratedAccessors)

- (void)addLayersObject:(ShopImageLayerEntity *)value;
- (void)removeLayersObject:(ShopImageLayerEntity *)value;
- (void)addLayers:(NSSet *)values;
- (void)removeLayers:(NSSet *)values;

@end
