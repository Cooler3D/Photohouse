//
//  AddressEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/22/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectProfile.h"

@class ProfileUserEntity;

@interface AddressEntity : PHObjectProfile

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) ProfileUserEntity *profile;

@end
