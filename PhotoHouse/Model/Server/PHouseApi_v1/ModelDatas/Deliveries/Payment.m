//
//  Payment.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/16/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "Payment.h"

NSString *const PAYMENT_NAME = @"name";
NSString *const PAYMENT_UIMANE = @"uiname";
NSString *const PAYMENT_ACTION = @"action";

@implementation Payment

- (id) initPaymentType:(NSString *)paymentType andDictionaryPayment:(NSDictionary *)payment
{
    self = [super init];
    if (self)
    {
        _paymentType = paymentType;
        _name   = [payment objectForKey:PAYMENT_NAME];
        _uiname = [payment objectForKey:PAYMENT_UIMANE];
        _action = [payment objectForKey:PAYMENT_ACTION];
    }
    
    return self;
}



- (id) initPaymentType:(NSString *)paymentType andPaymentName:(NSString *)name andPaymentUIname:(NSString *)uiname andAction:(NSString *)action
{
    self = [super init];
    if (self)
    {
        _paymentType = paymentType;
        _name   = name;
        _uiname = uiname;
        _action = action;
    }
    
    return self;
}


-(BOOL)isPrePayment
{
    return [_name isEqualToString:@"pre"];
}

@end
