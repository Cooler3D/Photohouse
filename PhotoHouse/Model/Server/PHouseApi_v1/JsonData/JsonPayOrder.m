//
//  JsonPayOrder.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/28/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "JsonPayOrder.h"

@implementation JsonPayOrder
@synthesize jsonDictionary = _jsonDictionary;

-(id)initJsonOrderID:(NSString *)order_id
{
    self = [super init];
    if (self) {
        [self createJsonOrderID:order_id];
    }
    return self;
}

- (void) createJsonOrderID:(NSString *)order_id
{
    NSString * timestamp = [self getTimeStamp];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    ACT_PAY_ORDER,      FIELD_ACT,
                                    order_id,           @"id",
                                    timestamp,          FIELD_TIME,
                                    nil];
    _jsonDictionary = jsonDictionary;
}
@end
