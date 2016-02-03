//
//  CookieModel.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/15/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "CookieModel.h"

NSString *const INSTAGRAM_COOKIE = @"instagram";
NSString *const VKONTAKTE_COOKIE = @"vk.com";

@implementation CookieModel
- (void) clearCookieWithName:(NSString*)nameCookie {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        //
        //NSLog(@"cookie: %@; Properties: %@", [cookie name], [cookie properties]);
        
        BOOL isDNeedDelete = [self findCookieName:nameCookie withDictionary:cookie.properties];
        if (isDNeedDelete) {
            [storage deleteCookie:cookie];
        }
    }
}

- (BOOL) findCookieName:(NSString*)nameCookie withDictionary:(NSDictionary*)dictionary
{
    NSString *domain = [dictionary objectForKey:@"Domain"];
    
    NSInteger index = [domain rangeOfString:nameCookie].location;
    
    if (index == NSNotFound) {
        return NO;
    }
    
    return YES;
}
@end
