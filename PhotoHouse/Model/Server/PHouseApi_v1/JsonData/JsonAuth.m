//
//  JsonAuth.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 28/06/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import "JsonAuth.h"

#import "NSString+MD5.h"

#import "PHRequestCommand.h"

@implementation JsonAuth
@synthesize jsonDictionary = _jsonDictionary;
- (id) initAuthEMail:(NSString *)login andPasswordHash:(NSString *)passwordHash
{
    self = [super init];
    if (self) {
        [self createJsonAuthEMail:login andPasswordHash:passwordHash];
    }
    return self;
}

- (void) createJsonAuthEMail:(NSString *)login andPasswordHash:(NSString *)passwordHash
{
    NSString * timestamp = [self getTimeStamp];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    ACT_AUTH,           @"act",
                                    login,              @"email",
                                    passwordHash,       @"password",
                                    timestamp,          @"time",
                                    nil];

    
    _jsonDictionary = jsonDictionary;
}
@end
