//
//  DeliveryStrategy.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 4/15/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "DeliveryStrategy.h"

#import "DeliveryCity.h"
#import "DeliveryType.h"
#import "Payment.h"

@implementation DeliveryStrategy
-(NSDictionary *)props
{
    DeliveryCity *delivery = self.storeItem.delivery;
    return [delivery getDeliveryProps];

}
@end
