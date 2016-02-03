//
//  ReguestRestorePass.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/6/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "RequestRestorePass.h"

#import "PHRequestCommand.h"
@implementation RequestRestorePass
- (id) initRestorePassWithEmail:(NSString *)email
{
    self = [super init];
    if (self) {
        [self createRequestWithEmail:email];
    }
    return self;
}


- (void) createRequestWithEmail:(NSString *)email
{
    NSString * timestamp = [self getTimeStamp];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    ACT_RESTORE_PASS,   FIELD_ACT,
                                    email,              @"email",
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