//
//  JsonGetCommands.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/28/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "JsonGetCommands.h"

@implementation JsonGetCommands
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
                                    @"get_api_commands",    FIELD_ACT,
                                    timestamp,              FIELD_TIME,
                                    nil];
    
    _jsonDictionary = jsonDictionary;
}

@end
