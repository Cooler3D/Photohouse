//
//  ShopCartSettingEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/5/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectShopCart.h"

@class ShopCartImageEntity;

@interface ShopCartSettingEntity : PHObjectShopCart

@property (nonatomic, retain) NSNumber * brightness;
@property (nonatomic, retain) NSNumber * constast;
@property (nonatomic, retain) NSString * crop;
@property (nonatomic, retain) NSString * filterName;
@property (nonatomic, retain) NSNumber * orientation;
@property (nonatomic, retain) NSNumber * orientationDefault;
@property (nonatomic, retain) NSNumber * saturation;
@property (nonatomic, retain) ShopCartImageEntity *image;

@end
