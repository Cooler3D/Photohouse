//
//  JsonCancelOrder.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/28/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "JsonCancelOrder.h"

//#import "CoreDataProfile.h"

@implementation JsonCancelOrder
@synthesize jsonDictionary = _jsonDictionary;
- (id) initJsonOrderID:(NSString *)order_id andUserID:(NSString *)user_id
{
    self = [super init];
    if (self) {
        [self createJsonOrderID:order_id andUserID:user_id];
    }
    return self;
}

- (void) createJsonOrderID:(NSString *)order_id andUserID:(NSString *)user_id
{
    // Request
    NSString * timestamp = [self getTimeStamp];
    
//    CoreDataProfile *profile = [[CoreDataProfile alloc] init];
//    NSString *token = [self getTokenWithUserID:[profile profileID] andTimeStamp:timestamp andOldPasswordMD5:[profile passowrdMD5]];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    ACT_CANCEL_ORDER,       FIELD_ACT,
                                    user_id,                @"id",
                                    order_id,               @"order_id",
                                    @"not used",            @"comment",
                                    @"",                    @"token",
                                    timestamp,              FIELD_TIME,
                                    nil];
    _jsonDictionary = jsonDictionary;
}

@end
