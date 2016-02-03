//
//  PropStyleEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/27/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PropStyleEntity : NSManagedObject

@property (nonatomic, retain) NSString * styleName;
@property (nonatomic, retain) NSNumber * maxCount;
@property (nonatomic, retain) NSNumber * minCount;
@property (nonatomic, retain) NSData * styleImage;
@property (nonatomic, retain) NSManagedObject *propType;

@end
