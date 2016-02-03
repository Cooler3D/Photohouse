//
//  SocialImageEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/13/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SocialImageEntity : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * library;

@end
