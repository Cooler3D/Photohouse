//
//  InstagramAccessToken.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/11/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "InstagramAccessToken.h"

@implementation InstagramAccessToken


+ (InstagramAccessToken*) initWithDictionary:(NSDictionary*)dictionary {
    static InstagramAccessToken *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[InstagramAccessToken alloc] init];
        [instance parseDictionary:dictionary];
    });
    
    
    return instance;
}




- (void) parseDictionary:(NSDictionary*)dictionary {
    
    for (NSString *key in [dictionary allKeys]) {
        // Key == user
        if ([key isEqualToString:@"user"]) {
            NSDictionary *userDictionary = [dictionary objectForKey:key];
            
            //NSLog(@"user: %@", [userDictionary objectForKey:@"username"]);
            _user_id = [userDictionary objectForKey:@"id"];
            _fullname = [userDictionary objectForKey:@"full_name"];
            _username = [userDictionary objectForKey:@"username"];
        }
        
        // Key == access_token
        if ([key isEqualToString:@"access_token"]) {
            //NSLog(@"access_token: %@", [dictionary objectForKey:key]);
            _accessToken = [dictionary objectForKey:key];
        }
    }

}

@end
