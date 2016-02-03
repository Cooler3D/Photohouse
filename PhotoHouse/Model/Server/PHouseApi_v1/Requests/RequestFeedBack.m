//
//  RequestFeedBack.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/8/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "RequestFeedBack.h"

#import "PHRequestCommand.h"
@implementation RequestFeedBack
- (id) initWithFeedBackType:(NSInteger)feedBackType
                   andTitle:(NSString*)title
             andMessageText:(NSString*)message
                   andEmail:(NSString*)email
{
    self = [super init];
    if (self) {
        [self createRequestWithFeedBackType:feedBackType andTitle:title andMesage:message andEmail:email];
    }
    
    return self;
}



- (void) createRequestWithFeedBackType:(NSInteger)feedBackType andTitle:(NSString *)title andMesage:(NSString *)message andEmail:(NSString *)email
{
    // Прменяем кодировку
    /*title   = [title stringByAddingPercentEscapesUsingEncoding:NSWindowsCP1251StringEncoding];
    message = [message stringByAddingPercentEscapesUsingEncoding:NSWindowsCP1251StringEncoding];*/
    
    
    NSString * timestamp = [self getTimeStamp];
    NSString * feedBackTypeStr = [NSString stringWithFormat:@"%li", (unsigned long)feedBackType];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    ACT_FEEDBACK,       @"act",
                                    feedBackTypeStr,    @"type",
                                    email,              @"email",
                                    title,              @"title",
                                    message,            @"message",
                                    timestamp,          @"time",
                                    nil];
    
    
    
    
    //
    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
    //NSLog(@"jsonData as string:\n%@", jsonString);
    
    
    
    
    // Кодируем данные
    NSMutableData *postData = [NSMutableData data];
    [postData appendData:[[NSString stringWithFormat:@"%@", jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //
    [self setURL:[NSURL URLWithString:SERVER_URL]];
    [self setValue:[self getDeviceName] forHTTPHeaderField:@"User-Agent"];
    [self setHTTPMethod:@"POST"];
    [self setHTTPBody:postData];
}
@end
