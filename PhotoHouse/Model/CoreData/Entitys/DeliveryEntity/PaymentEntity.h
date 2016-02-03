//
//  PaymentEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/16/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DeliveryTypeEntity;

@interface PaymentEntity : NSManagedObject

@property (nonatomic, retain) NSString * paymentType;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uiname;
@property (nonatomic, retain) NSString * action;
@property (nonatomic, retain) DeliveryTypeEntity *delivery;

@end
