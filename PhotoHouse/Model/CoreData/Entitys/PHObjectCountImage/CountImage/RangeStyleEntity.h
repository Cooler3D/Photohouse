//
//  RangeStyleEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/8/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectStyleEntity.h"

@class StyleTypeEntity;

@interface RangeStyleEntity : PHObjectStyleEntity

@property (nonatomic, retain) NSNumber * maxCount;
@property (nonatomic, retain) NSNumber * minCount;
@property (nonatomic, retain) NSString * nameStyle;
@property (nonatomic, retain) StyleTypeEntity *styleStyles;

@end
