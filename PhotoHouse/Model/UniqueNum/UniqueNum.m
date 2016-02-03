//
//  UniqueNum.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/5/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "UniqueNum.h"

@implementation UniqueNum
+ (NSUInteger) getUniqueID
{
    NSDate *date = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *component = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth |
                                   NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute |
                                   NSCalendarUnitSecond
                                              fromDate:date];
    
    NSUInteger index = 999999 - [component year] - [component day] - [component hour] - [component minute] - [component second] - arc4random_uniform(10000);
    //NSLog(@"index: %i", index);
    
    return index;
}
@end
