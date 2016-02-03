//
//  CityDeliveries.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/24/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "DeliveryCity.h"
#import "DeliveryType.h"

NSString *const DELIVERY_NAME           = @"name";
NSString *const DELIVERY_UINAME         = @"uiname";
NSString *const DELIVERY_DELIVERIES     = @"deliveries";


@implementation DeliveryCity

- (id) initWithCityDictionary:(NSDictionary *)cityDictionary andDictionaryPayments:(NSDictionary *)payments
{
    self = [super init];
    if (self) {
        //
        _name = [cityDictionary objectForKey:DELIVERY_NAME];
        _uiname = [cityDictionary objectForKey:DELIVERY_UINAME];
        NSArray *deliveries = [cityDictionary objectForKey:DELIVERY_DELIVERIES];
        [self parseDeliveries:deliveries andDictionaryPayments:payments];
    }
    return self;
}


- (id) initWitName:(NSString *)name andUIname:(NSString *)uiname andSetTypes:(NSArray *)types
{
    self = [super init];
    if (self) {
        //
        _name = name;
        _uiname = uiname;
        _types = types;
    }
    return self;
}

- (void) parseDeliveries:(NSArray *)deliveries andDictionaryPayments:(NSDictionary *)payments
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *delType in deliveries) {
        DeliveryType *deliveryType = [[DeliveryType alloc] initDeliveryTypeDictionary:delType andDictionaryPayments:payments];
        [array addObject:deliveryType];
    }
    
    //
    _types = [array copy];
}


- (NSDictionary *) getDeliveryProps
{
    NSString *type = [(DeliveryType*)[self.types firstObject] type];
    NSString *code = [(DeliveryType*)[self.types firstObject] code];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:  type,  @"type",
                                                                            _name, @"city",
                                                                            code,  @"code", nil];
    return dictionary;
}
@end
