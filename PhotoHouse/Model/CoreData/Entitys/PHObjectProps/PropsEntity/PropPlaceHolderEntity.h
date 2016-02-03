//
//  PropPlaceHolderEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/8/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectProps.h"

@class PropLayoutEntity;

@interface PropPlaceHolderEntity : PHObjectProps

@property (nonatomic, retain) NSString * psdPath;
@property (nonatomic, retain) NSString * layerNum;
@property (nonatomic, retain) NSString * pngPath;
@property (nonatomic, retain) NSString * rect;
@property (nonatomic, retain) PropLayoutEntity *layout;

@end
