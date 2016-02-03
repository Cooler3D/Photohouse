//
//  JsonRegistration.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/28/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "JsonRegistration.h"

#import "NSString+MD5.h"

#import "PHRequestCommand.h"

@implementation JsonRegistration
@synthesize jsonDictionary = _jsonDictionary;

-(id)initJsonRegistationPhotoHouseFirstName:(NSString *)firstname
                                andLastName:(NSString *)lastName
                                   andEmail:(NSString *)email
                               withPassword:(NSString *)password
{
    self = [super init];
    if (self) {
        [self createJsonWithFirstName:firstname andLastName:lastName andEmail:email withPassword:password];
    }
    return self;
}


- (void) createJsonWithFirstName:(NSString *)firstname
                     andLastName:(NSString *)lastName
                        andEmail:(NSString *)email
                    withPassword:(NSString *)password
{
    NSString * timestamp = [self getTimeStamp];
    
    NSString *salt = [NSString stringWithFormat:@"%@%@", SALT, password];
    NSString *pass = [salt MD5];
    
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

    
    
    _jsonDictionary = jsonDictionary;
}

@end
