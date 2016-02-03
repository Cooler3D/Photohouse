//
//  RequestAuth.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/24/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "RequestAuth.h"

#import "NSString+MD5.h"
#import "PHouseApi.h"
#import "Acts.h"

#import "PHRequestCommand.h"
@interface RequestAuth ()
@property (strong, nonatomic) NSString *login;
@property (strong, nonatomic) NSString *passwordMD5;
@end

@implementation RequestAuth
- (id) initAuthEMail:(NSString *)login
      andPasswordMD5:(NSString *)passwordMD5
{
    self = [super init];
    if (self) {
        _login          = login;
        _passwordMD5    = passwordMD5;
        [self createRequest];
    }
    return self;
}


- (void) createRequest
{
    // Save To App
    /*NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:_login forKey:APPLICATION_LOGIN];
    [userDefault setObject:_password forKey:APPLICATION_PASSWORD];
    [userDefault synchronize];*/
    
    // Request
    NSString * timestamp = [self getTimeStamp];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    ACT_AUTH,           @"act",
                                    _login,             @"email",
                                    _passwordMD5,       @"password",
                                    timestamp,          @"time",
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
