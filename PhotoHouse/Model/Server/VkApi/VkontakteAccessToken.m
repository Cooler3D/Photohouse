//
//  VkontakteAccessToken.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/12/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "VkontakteAccessToken.h"

NSString *ACCESS_TOKEN = @"access_token";
NSString *USER_ID = @"user_id";
NSString *E_MAIL = @"email";

@implementation VkontakteAccessToken

+ (VkontakteAccessToken*) initializeWithArrayTokenKeys:(NSArray*)keys {
    static VkontakteAccessToken *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[VkontakteAccessToken alloc] init];
    });
    
    [instance parseKeys:keys];

    return instance;
}



- (void) parseKeys:(NSArray*)keys {
    
    for (NSString *key in keys) {
        NSInteger loc = [key rangeOfString:ACCESS_TOKEN].location;
        
        
        if (loc != NSNotFound) {
            _accessToken = [key substringFromIndex:loc + 13];
        }
        
        
        loc = [key rangeOfString:USER_ID].location;
        if (loc != NSNotFound) {
            _user_id = [key substringFromIndex:loc + 8];
        }
        
        
        
        loc = [key rangeOfString:E_MAIL].location;
        if (loc != NSNotFound) {
            _email = [key substringFromIndex:loc + 6];
        }
    }
}
@end
