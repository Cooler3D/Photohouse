//
//  JsonGetBanner.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/26/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "JsonGetBanner.h"


@implementation JsonGetBanner
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
    
//    NSString *device = [self getDeviceName];
//    
//    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    ACT_GET_BANNERS,    @"act",
//                                    @"ios",             @"type",
//                                    device,             @"screen",
//                                    timestamp,          @"time",
//                                    nil];
    
    NSDictionary *jsonDictionary = @{@"act":    ACT_GET_BANNERS,
                                     @"type":   @"ios",
                                     //@"screen": device,
                                     @"time":   timestamp};
    
    _jsonDictionary = jsonDictionary;
    //
//    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
//    _jsonString = jsonString;
}
@end
