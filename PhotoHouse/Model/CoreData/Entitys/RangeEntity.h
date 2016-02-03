//
//  RangeEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/8/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RangeEntity : NSManagedObject

@property (nonatomic, retain) NSString * nameType;
@property (nonatomic, retain) NSString * nameStyle;
@property (nonatomic, retain) NSNumber * minRange;
@property (nonatomic, retain) NSNumber * maxRange;
@property (nonatomic, retain) NSNumber * purchaseID;

@end
