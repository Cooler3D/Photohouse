//
//  RequestAllOrders.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/8/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "RequestGetAllOrders.h"

#import "CoreDataProfile.h"

#import "NSString+MD5.h"


#import "PHRequestCommand.h"
@implementation RequestGetAllOrders
- (id) initAllOrdes
{
    self = [super init];
    if (self) {
        [self createRequest];
    }
    return self;
}



- (void) createRequest
{
    /*NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *login = [userDefaults objectForKey:APPLICATION_LOGIN];
    NSString *pass  = [userDefaults objectForKey:APPLICATION_PASSWORD];
    
    if (!login || !pass) {
        //[self.delegate photoHouseError:@"Требуется логин и пароль" withErrorCode:ErrorCodeTypeNotLoginAndPassword];
        return;
    }*/
    
    
    //
    NSString * timestamp = [self getTimeStamp];
    
    //
    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
    NSString *profileId = [coreProfile profileID];
    NSString *sig = [self createSigWithGetOrderUserID:profileId andTime:timestamp];
    
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    ACT_GET_ALL_ORDERS,         @"act",
                                    profileId,                  @"user_id",
                                    sig,                        @"sig",
                                    timestamp,                  @"time",
                                    nil];
    
    
    //
    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
    
    
    
    
    // Кодируем данные
    NSMutableData *postData = [NSMutableData data];
    [postData appendData:[[NSString stringWithFormat:@"%@", jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
    

    
    //
    [self setURL:[NSURL URLWithString:SERVER_URL]];
    [self setValue:[self getDeviceName] forHTTPHeaderField:@"User-Agent"];
    [self setHTTPMethod:@"POST"];
    [self setHTTPBody:postData];
}



- (NSString*) createSigWithGetOrderUserID:(NSString*)user_id andTime:(NSString*)time {
    NSString *salt = @"wOwsAlTsoSaLt$o$aFeVERYsecure";
    
    NSString *params = [NSString stringWithFormat:@"act=get_all_ordersuser_id=%@time=%@", user_id, time];
    
    NSString *paramsMD5 = [params MD5];
    
    NSString *paramMD5PlusSalt = [paramsMD5 stringByAppendingString:salt];
    
    NSString *allMD5 = [paramMD5PlusSalt MD5];
    
    return allMD5;
}

@end
