//
//  JsonFeedBack.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/28/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "JsonFeedBack.h"

@implementation JsonFeedBack
@synthesize jsonDictionary = _jsonDictionary;

- (id) initWithFeedBackType:(NSInteger)feedBackType
                   andTitle:(NSString*)title
             andMessageText:(NSString*)message
                   andEmail:(NSString*)email
{
    self = [super init];
    if (self) {
        [self createJsonFeedBackType:feedBackType andTitle:title andMesage:message andEmail:email];
    }
    return self;
}

- (void) createJsonFeedBackType:(NSInteger)feedBackType andTitle:(NSString *)title andMesage:(NSString *)message andEmail:(NSString *)email
{
    // Прменяем кодировку
    /*title   = [title stringByAddingPercentEscapesUsingEncoding:NSWindowsCP1251StringEncoding];
     message = [message stringByAddingPercentEscapesUsingEncoding:NSWindowsCP1251StringEncoding];*/
    
    
    NSString * timestamp = [self getTimeStamp];
    NSString * feedBackTypeStr = [NSString stringWithFormat:@"%li", (unsigned long)feedBackType];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    ACT_FEEDBACK,       @"act",
                                    feedBackTypeStr,    @"type",
                                    email,              @"email",
                                    title,              @"title",
                                    message,            @"message",
                                    timestamp,          @"time",
                                    nil];
    _jsonDictionary = jsonDictionary;
}

    
    
    

@end
