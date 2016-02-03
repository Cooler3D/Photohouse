//
//  PersonOrderInfo.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/20/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PersonOrderInfo.h"



@implementation PersonOrderInfo
- (id) initWithOrderInfo:(NSDictionary *)orderInfo
{
    self = [super init];
    if (self) {
        [self parseOrderInfo:orderInfo];
    }
    return self;
}

- (void) parseOrderInfo:(NSDictionary *)orderInfo
{
    _order_id           = [orderInfo objectForKey:@"id"];
    _user_id            = [orderInfo objectForKey:@"user_id"];
    _studio_id          = [orderInfo objectForKey:@"studio_id"];
    _fullName           = [orderInfo objectForKey:@"full_name"];
    _dateString         = [orderInfo objectForKey:@"date"];
    _phone              = [orderInfo objectForKey:@"phone"];
    _address            = [orderInfo objectForKey:@"address"];
    _deliveryComment    = [orderInfo objectForKey:@"description"];
    _status             = [orderInfo objectForKey:@"status"];
    _status_id          = [orderInfo objectForKey:@"status_id"];
    _total_cost         = [orderInfo objectForKey:@"total_cost"];
}


-(UIImage *)statusImage
{
    StatusOrderType statusType = (StatusOrderType)[_status_id integerValue];
    UIImage *statusImage = nil;
    switch (statusType) {
        case StatusOrderTypeWait:
            statusImage = [UIImage imageNamed:@"waiting"];
            break;
            
        case StatusOrderTypeTick:
            statusImage = [UIImage imageNamed:@"tick"];
            break;
            
        case StatusOrderTypePrint:
            statusImage = [UIImage imageNamed:@"printer"];
            break;
            
        case StatusOrderTypeDelivery:
            statusImage = [UIImage imageNamed:@"delivery"];
            break;
            
        case StatusOrderTypeComplete:
            statusImage = [UIImage imageNamed:@"ready"];
            break;
            
        case StatusOrderTypeCancel:
            statusImage = [UIImage imageNamed:@"cancel"];
            break;
            
        case StatusOrderTypePayment:
            statusImage = [UIImage imageNamed:@"payment"];
            break;
    }
    
    return statusImage;
}
@end
