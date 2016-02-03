//
//  DeliveryMemberEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/22/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectProfile.h"

@class ProfileUserEntity;

@interface DeliveryMemberEntity : PHObjectProfile

@property (nonatomic, retain) NSString * codeDelivery;
@property (nonatomic, retain) NSString * uiCityName;
@property (nonatomic, retain) NSString * uiPaymentName;
@property (nonatomic, retain) ProfileUserEntity *profile;

@end
