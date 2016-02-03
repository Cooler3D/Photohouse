//
//  JsonGetAddress.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/28/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "JsonGetAddress.h"


#import "CoreDataProfile.h"

@implementation JsonGetAddress
@synthesize jsonDictionary = _jsonDictionary;
-(id)init
{
    self = [super init];
    if (self) {
        [self createJson];
    }
    return self;
}

- (void) createJson
{
    NSString * timestamp = [self getTimeStamp];
    
    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
    NSString *profileid = [coreProfile profileID];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    ACT_GET_ADDRESSLIST,    @"act",
                                    profileid,              @"user_id",
                                    @"",                    @"sig",
                                    timestamp,              @"time",
                                    nil];
    
    
    _jsonDictionary = jsonDictionary;
}

@end
