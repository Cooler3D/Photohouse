//
//  JsonGetTemplates.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/28/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "JsonGetTemplates.h"

#import "DeviceManager.h"

@implementation JsonGetTemplates
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
    
//    DeviceManager *manager = [[DeviceManager alloc] init];
//    NSString *sizeModel =  [manager getDeviceModelName];
    
    NSDictionary *jsonDictionary = @{FIELD_ACT:     ACT_GET_ALBUM_TEMPLATE,
                                     FIELD_TIME:    timestamp,
                                     @"size":       @"4"};
    
    _jsonDictionary = jsonDictionary;
}

@end
