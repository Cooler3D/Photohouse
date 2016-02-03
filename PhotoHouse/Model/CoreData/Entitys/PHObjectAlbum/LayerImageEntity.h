//
//  LayerImageEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/19/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectAlbum.h"

@class LayoutEntity;

@interface LayerImageEntity : PHObjectAlbum

@property (nonatomic, retain) NSNumber * layertype;
@property (nonatomic, retain) NSNumber * pixelMin;
@property (nonatomic, retain) NSNumber * pixelLimit;
@property (nonatomic, retain) NSNumber * z;
@property (nonatomic, retain) NSString * rect;
@property (nonatomic, retain) NSString * crop;
@property (nonatomic, retain) NSString * urlUpload;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) LayoutEntity *layout;

@end
