//
//  RequestConstructorTemplate.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/26/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "RequestAlbum.h"

#import "PHRequestCommand.h"
@implementation RequestAlbum
-(id)init
{
    self = [super init];
    if (self) {
        NSString * timestamp = [self getTimeStamp];
        
        NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        ACT_GET_ALBUM_TEMPLATE, @"act",
                                        timestamp,              @"time",
                                        nil];
        
        
        //
        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
        NSLog(@"jsonData as string:\n%@", jsonString);
        
        
        // Кодируем данные
        NSMutableData *postData = [NSMutableData data];
        [postData appendData:[[NSString stringWithFormat:@"%@", jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        [self setURL:[NSURL URLWithString:SERVER_URL]];
        [self setValue:[self getDeviceName] forHTTPHeaderField:@"User-Agent"];
        [self setHTTPMethod:@"POST"];
        [self setHTTPBody:postData];
    }
    return self;
}
@end
