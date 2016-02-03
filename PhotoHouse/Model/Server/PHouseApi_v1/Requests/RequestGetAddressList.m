//
//  RequestGetAddressList.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/26/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "RequestGetAddressList.h"

#import "NSString+MD5.h"

#import "CoreDataProfile.h"

#import "PHRequestCommand.h"

@implementation RequestGetAddressList

- (id)initWithAddresslist
{
    self = [super init];
        
    
    NSString * timestamp = [self getTimeStamp];
    
    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
    NSString *profileid = [coreProfile profileID];
    
    NSString *sig = [self createSigWithUserID:profileid andTime:timestamp];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    ACT_GET_ADDRESSLIST,    @"act",
                                    profileid,              @"user_id",
                                    sig,                    @"sig",
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

    return self;
}




- (NSString*) createSigWithUserID:(NSString*)user_id andTime:(NSString*)time {
    NSString *salt = @"wOwsAlTsoSaLt$o$aFeVERYsecure";
    
    NSString *params = [NSString stringWithFormat:@"act=get_all_ordersuser_id=%@time=%@", user_id, time];
    
    NSString *paramsMD5 = [params MD5];
    
    NSString *paramMD5PlusSalt = [paramsMD5 stringByAppendingString:salt];
    
    NSString *allMD5 = [paramMD5PlusSalt MD5];
    
    return allMD5;
}

@end
