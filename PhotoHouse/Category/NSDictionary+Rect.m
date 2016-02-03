//
//  NSDictionary+Rect.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/3/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "NSDictionary+Rect.h"

@implementation NSDictionary (Rect)
+ (NSDictionary*) dictionaryFromCGRect:(CGRect)rect {
    NSInteger posX = rect.origin.x;
    NSInteger posY = rect.origin.y;
    NSInteger width = rect.size.width;
    NSInteger height = rect.size.height;
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%li", (long)posX],        @"x",
                                [NSString stringWithFormat:@"%li", (long)posY],        @"y",
                                [NSString stringWithFormat:@"%li", (long)width],       @"width",
                                [NSString stringWithFormat:@"%li", (long)height],      @"height", nil];
    return dictionary;
}



/**
 Приходит такая строка:
 { height = 80;
 width = 90;
 x = 0;
 y = 0;
 }
 */
+(CGRect)getCGRectWithString:(NSString *)rectScting
{
    rectScting = [rectScting stringByReplacingOccurrencesOfString:@" " withString:@""];
    rectScting = [rectScting stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    rectScting = [rectScting stringByReplacingOccurrencesOfString:@"}" withString:@""];
    rectScting = [rectScting stringByReplacingOccurrencesOfString:@"{" withString:@""];
    
    NSArray *array = [rectScting componentsSeparatedByString:@";"];
    
    CGRect rect = CGRectMake([self getFloatWithFindString:@"x=" withArr:array],
                             [self getFloatWithFindString:@"y=" withArr:array],
                             [self getFloatWithFindString:@"width=" withArr:array],
                             [self getFloatWithFindString:@"height=" withArr:array]);
    return rect;
}





+ (CGFloat) getFloatWithFindString:(NSString *)str withArr:(NSArray *)array
{
    NSString *final;
    for (NSString *param in array) {
        NSInteger loc = [param rangeOfString:str].location;
        if (loc != NSNotFound) {
            final = param;
        }
    }
    
    // Нашли
    final = [final substringWithRange:NSMakeRange(str.length, final.length - str.length)];
    return [final floatValue];
}
@end
