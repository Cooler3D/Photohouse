//
//  JsonGetItems.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/26/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "JsonGetItems.h"

@implementation JsonGetItems
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
//    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    ACT_GET_ITEMS,      @"act",
//                                    timestamp,          @"time",
//                                    nil];
    NSDictionary *jsonDictionary = @{@"act":    ACT_GET_ITEMS,
                                     @"time":   timestamp};
    
    _jsonDictionary = jsonDictionary;
//    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
//    NSLog(@"jsonData as string:\n%@", jsonString);
//    _jsonString = jsonString;
}
@end
