//
//  NSDate+ServerTime.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/6/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "NSDate+ServerTime.h"

@implementation NSDate (ServerTime)

+ (NSString *) convertFromServerTime:(NSString *)regDate
{
//    NSString *serverTime = @"1436128225.9525";
//    NSTimeInterval interval = [regDate doubleValue];
    NSDate *date = [self convertToDateWithServerTimer:regDate];
    NSDateFormatter *formatter = [self getFormatterDate];
    NSString *result = [formatter stringFromDate:date];
    return result;
}



+ (NSDate *) convertToDateWithServerTimer:(NSString *)regDate
{
    NSTimeInterval interval = [regDate doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [self getFormatterDate];
    [formatter setDefaultDate:date];
    return date;
}


+ (NSDateFormatter *) getFormatterDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return formatter;
}
@end
