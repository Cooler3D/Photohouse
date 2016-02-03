//
//  ShopImageLayerEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/29/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectShopCart.h"


@interface ShopImageLayerEntity : PHObjectShopCart

@property (nonatomic, retain) NSString * crop;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * layerType;
@property (nonatomic, retain) NSNumber * pixelLimit;
@property (nonatomic, retain) NSNumber * pixelMin;
@property (nonatomic, retain) NSString * rect;
@property (nonatomic, retain) NSString * urlUpload;
@property (nonatomic, retain) NSString * urlPage;
@property (nonatomic, retain) NSString * z;
@property (nonatomic, retain) NSNumber * orientation;
@property (nonatomic, retain) NSNumber * orientationDefault;
@property (nonatomic, retain) NSManagedObject *layout;

@end
