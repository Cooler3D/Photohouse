//
//  RequestCancelOrder.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/23/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "RequestCancelOrder.h"
#import "CoreDataProfile.h"

#import "PHRequestCommand.h"
@implementation RequestCancelOrder
- (id) initWithOrderID:(NSString *)order_id andUserID:(NSString *)user_id
{
    self = [super init];
    if (self) {
        [self createRequestWithOrderID:order_id andUserID:user_id];
    }
    return self;
}

- (void) createRequestWithOrderID:(NSString *)order_id andUserID:(NSString *)user_id
{
    // Request
    NSString * timestamp = [self getTimeStamp];
    
    CoreDataProfile *profile = [[CoreDataProfile alloc] init];
    NSString *token = [self getTokenWithUserID:[profile profileID] andTimeStamp:timestamp andOldPasswordMD5:[profile passowrdMD5]];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    ACT_CANCEL_ORDER,       FIELD_ACT,
                                    user_id,                @"id",
                                    order_id,               @"order_id",
                                    @"not used",            @"comment",
                                    token,                  @"token",
                                    timestamp,              FIELD_TIME,
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
