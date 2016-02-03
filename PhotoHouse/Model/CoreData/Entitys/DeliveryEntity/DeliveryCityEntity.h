//
//  DeliveryCityEntity.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/25/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DeliveryTypeEntity;

@interface DeliveryCityEntity : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uiname;
@property (nonatomic, retain) NSSet *deliveries;
@end

@interface DeliveryCityEntity (CoreDataGeneratedAccessors)

- (void)addDeliveriesObject:(DeliveryTypeEntity *)value;
- (void)removeDeliveriesObject:(DeliveryTypeEntity *)value;
- (void)addDeliveries:(NSSet *)values;
- (void)removeDeliveries:(NSSet *)values;

@end
