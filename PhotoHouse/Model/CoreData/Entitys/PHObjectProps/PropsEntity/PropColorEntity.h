//
//  PropColorEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/10/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectProps.h"

@class PropTypeEntity;

@interface PropColorEntity : PHObjectProps

@property (nonatomic, retain) NSString * colorName;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) PropTypeEntity *propType;

@end
