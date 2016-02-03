//
//  PropUturnEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/30/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectProps.h"

@class PropTypeEntity;

@interface PropUturnEntity : PHObjectProps

@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * uturn;
@property (nonatomic, retain) PropTypeEntity *propType;

@end
