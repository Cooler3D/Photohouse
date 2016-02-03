//
//  PropLayerImageEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/28/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectProps.h"

@class PropLayoutEntity;

@interface PropLayerImageEntity : PHObjectProps

@property (nonatomic, retain) NSString * crop;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * pixelLimit;
@property (nonatomic, retain) NSNumber * pixelMin;
@property (nonatomic, retain) NSString * rect;
@property (nonatomic, retain) NSNumber * z;
@property (nonatomic, retain) NSNumber * layerType;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) PropLayoutEntity *layout;

@end
