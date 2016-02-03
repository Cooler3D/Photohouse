//
//  NSDate+ServerTime.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/6/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ServerTime)
+ (NSString *) convertFromServerTime:(NSString *)regDate;

+ (NSDate *) convertToDateWithServerTimer:(NSString *)regDate;
@end
