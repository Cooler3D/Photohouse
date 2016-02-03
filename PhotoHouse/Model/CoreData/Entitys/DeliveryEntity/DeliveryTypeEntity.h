//
//  DeliveryTypeEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/16/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DeliveryCityEntity, PaymentEntity;

@interface DeliveryTypeEntity : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSNumber * cost;
@property (nonatomic, retain) NSString * descritions;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) DeliveryCityEntity *city;
@property (nonatomic, retain) NSSet *payments;
@end

@interface DeliveryTypeEntity (CoreDataGeneratedAccessors)

- (void)addPaymentsObject:(PaymentEntity *)value;
- (void)removePaymentsObject:(PaymentEntity *)value;
- (void)addPayments:(NSSet *)values;
- (void)removePayments:(NSSet *)values;

@end
