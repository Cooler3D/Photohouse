//
//  ProfileUserEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/23/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PHObjectProfile.h"

@class AddressEntity, DeliveryMemberEntity, PhoneEntity;

@interface ProfileUserEntity : PHObjectProfile

@property (nonatomic, retain) NSString * access;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * groupname;
@property (nonatomic, retain) NSString * idUser;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSString * regDate;
@property (nonatomic, retain) NSString * passwordMD5;
@property (nonatomic, retain) AddressEntity *address;
@property (nonatomic, retain) DeliveryMemberEntity *deliveryMember;
@property (nonatomic, retain) PhoneEntity *phone;

@end
