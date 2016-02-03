//
//  RequestRegistration.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/27/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "RequestRegistration.h"
#import "NSString+MD5.h"

#import "PHRequestCommand.h"
@implementation RequestRegistration

-(id)initWithRegistationPhotoHouseFirstName:(NSString *)firstname
                                andLastName:(NSString *)lastName
                                   andEmail:(NSString *)email
                               withPassword:(NSString *)password
{
    self = [super init];
    
    // Прменяем кодировку
    firstname = [firstname stringByAddingPercentEscapesUsingEncoding:NSWindowsCP1251StringEncoding];
    lastName = [lastName  stringByAddingPercentEscapesUsingEncoding:NSWindowsCP1251StringEncoding];
    
    
    NSString * timestamp = [self getTimeStamp];
    
    NSString *pass = [password MD5];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults objectForKey:APPLICATION_TOKEN];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    ACT_REGISTRATION,   @"act",
                                    firstname,          @"firstname",
                                    lastName,           @"lastname",
                                    email,              @"email",
                                    pass,               @"password",
                                    timestamp,          @"time",
                                    token,              @"token",
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
    return self;
}
@end
