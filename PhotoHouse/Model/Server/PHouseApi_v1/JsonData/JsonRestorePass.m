//
//  JsonRestorePass.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/28/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "JsonRestorePass.h"

@implementation JsonRestorePass
@synthesize jsonDictionary = _jsonDictionary;

-(id)initJsonEmail:(NSString *)email
{
    self = [super init];
    if (self) {
        [self createJsonEmail:email];
    }
    return self;
}


- (void) createJsonEmail:(NSString *)email
{
    NSString * timestamp = [self getTimeStamp];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    ACT_RESTORE_PASS,   FIELD_ACT,
                                    email,              @"email",
                                    timestamp,          FIELD_TIME,
                                    nil];
    _jsonDictionary = jsonDictionary;
}
@end
