//
//  JsonGetDeliveries.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 28/06/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import "JsonGetDeliveries.h"
#import "Acts.h"

@implementation JsonGetDeliveries
@synthesize jsonDictionary = _jsonDictionary;
-(id)init
{
    self = [super init];
    if (self) {
        [self createJson];
    }
    return self;
}

- (void) createJson
{
    NSString * timestamp = [self getTimeStamp];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    ACT_GET_DELIVERIES,     FIELD_ACT,
                                    timestamp,              FIELD_TIME,
                                    nil];
    
    _jsonDictionary = jsonDictionary;
}

@end
