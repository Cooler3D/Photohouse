//
//  DeliveryType.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/24/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "DeliveryType.h"
#import "Payment.h"

NSString *const DELIVERY_TYPE = @"type";
NSString *const DELIVERY_COST = @"cost";
NSString *const DELIVERY_CODE = @"code";
NSString *const DELIVERY_DESCRIPTION = @"description";


@implementation DeliveryType

- (id) initDeliveryTypeDictionary:(NSDictionary *)dictionary andDictionaryPayments:(NSDictionary *)payments
{
    self = [super init];
    if (self)
    {
        _type           = [dictionary objectForKey:DELIVERY_TYPE];
        _deldescription = [dictionary objectForKey:DELIVERY_DESCRIPTION];
        _cost           = [[dictionary objectForKey:DELIVERY_COST] integerValue];
        _code           = [dictionary objectForKey:DELIVERY_CODE];
        
        [self parseDictionaryPayments:payments];
    }
    
    return self;
}


- (id) initWithType:(NSString *)type
     andDescription:(NSString *)description
            andCode:(NSString *)code
            andCost:(NSInteger)cost
        andPayments:(NSArray *)payments
{
    self = [super init];
    if (self) {
        _type = type;
        _deldescription = description;
        _cost = cost;
        _code = code;
        _payments = payments;
    }
    return self;
}



- (void) parseDictionaryPayments:(NSDictionary *)payments
{
    NSString *payTypeKey = @"default";
    
    for (NSString *key in [payments allKeys]) {
        if ([key isEqualToString:_type]) {
            payTypeKey = key;
        }
    }
    
    //
    NSMutableArray *paymentsMutable = [NSMutableArray array];
    NSArray *paymentArray = [payments objectForKey:payTypeKey];
    for (NSDictionary *payment in paymentArray) {
        Payment *pay = [[Payment alloc] initPaymentType:payTypeKey andDictionaryPayment:payment];
        [paymentsMutable addObject:pay];
    }
    
    _payments = [paymentsMutable copy];
}
@end
