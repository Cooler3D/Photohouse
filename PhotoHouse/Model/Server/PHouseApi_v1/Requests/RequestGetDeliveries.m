//
//  ReqiestGetDeliveries.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/24/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "RequestGetDeliveries.h"

#import "PHRequestCommand.h"
@implementation RequestGetDeliveries

-(id)initRequestWithDeliveries {
    self = [super init];
    if (self) {
        [self createSelfRequest];
    }
    return self;
}



- (void) createSelfRequest
{
    NSString * timestamp = [self getTimeStamp];
        
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    ACT_GET_DELIVERIES,     FIELD_ACT,
                                    timestamp,              FIELD_TIME,
                                    nil];
    
    
    //
    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
    //NSLog(@"jsonData as string:\n%@", jsonString);
    
    
    // Кодируем данные
    NSMutableData *postData = [NSMutableData data];
    [postData appendData:[[NSString stringWithFormat:@"%@", jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [self setURL:[NSURL URLWithString:SERVER_URL]];
    [self setValue:[self getDeviceName] forHTTPHeaderField:@"User-Agent"];
    [self setHTTPMethod:@"POST"];
    [self setHTTPBody:postData];
}

@end
