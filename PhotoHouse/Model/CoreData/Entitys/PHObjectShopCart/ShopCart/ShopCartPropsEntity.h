//
//  ShopCartPropsEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/29/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectShopCart.h"

@class ShopCartPrintEntity, ShopTemplateEntity;

@interface ShopCartPropsEntity : PHObjectShopCart

@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSString * cover;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * size;
@property (nonatomic, retain) NSString * style;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * uturn;
@property (nonatomic, retain) ShopCartPrintEntity *print;
@property (nonatomic, retain) ShopTemplateEntity *templateAlbum;

@end
