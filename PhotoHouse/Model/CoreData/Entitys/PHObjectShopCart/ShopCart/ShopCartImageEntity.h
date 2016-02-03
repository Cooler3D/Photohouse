//
//  ShopCartImageEntity.h
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 08/04/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectShopCart.h"

@class ShopCartPrintEntity, ShopCartSettingEntity;

@interface ShopCartImageEntity : PHObjectShopCart

@property (nonatomic, retain) NSData * imageLarge;
@property (nonatomic, retain) NSData * imagePreview;
@property (nonatomic, retain) NSNumber * importLibrary;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSNumber * isMerged;
@property (nonatomic, retain) NSNumber * unique_image;
@property (nonatomic, retain) NSString * uploadURL;
@property (nonatomic, retain) NSString * urlLibrary;
@property (nonatomic, retain) NSString * sizeLargeImage;
@property (nonatomic, retain) ShopCartSettingEntity *imageSetting;
@property (nonatomic, retain) ShopCartPrintEntity *print;

@end
