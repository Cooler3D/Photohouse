//
//  BannerEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/9/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BannerEntity : NSManagedObject

@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * actionUrl;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * interval;

@end
