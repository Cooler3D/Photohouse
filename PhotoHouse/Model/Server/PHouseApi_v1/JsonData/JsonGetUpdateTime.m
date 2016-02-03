//
//  JsonGetUpdateTime.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/6/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "JsonGetUpdateTime.h"

@implementation JsonGetUpdateTime
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
                                    @"get_updates_time",    FIELD_ACT,
                                    timestamp,              FIELD_TIME,
                                    nil];
    
    _jsonDictionary = jsonDictionary;
}

@end
