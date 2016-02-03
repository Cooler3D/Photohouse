//
//  RequestPayOrder.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 26/01/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import "RequestPayOrder.h"

#import "PHRequestCommand.h"
@implementation RequestPayOrder

- (id) initWithOrderID:(NSString *)order_id
{
    self = [super init];
    if (self) {
        [self createRequestWithOrderID:order_id];
    }
    return self;
}


- (void) createRequestWithOrderID:(NSString *)order_id
{
    NSString * timestamp = [self getTimeStamp];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    ACT_PAY_ORDER,      FIELD_ACT,
                                    order_id,           @"id",
                                    timestamp,          FIELD_TIME,
                                    nil];
    
    
    
    //
    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
    //NSLog(@"jsonData as string:\n%@", jsonString);
    
    
    // Кодируем данные
    NSMutableData *postData = [NSMutableData data];
    //[postData appendData:[[NSString stringWithFormat:@"data=%@", stringFromBase64] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"%@", jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
    

    
    //
    [self setURL:[NSURL URLWithString:SERVER_URL]];
    [self setValue:[self getDeviceName] forHTTPHeaderField:@"User-Agent"];
    [self setHTTPMethod:@"POST"];
    [self setHTTPBody:postData];

}
@end
