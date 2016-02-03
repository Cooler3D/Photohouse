//
//  NSTimer+TimerSupport.h
//  TimerRepeat
//
//  Created by Мартынов Дмитрий on 14/01/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (TimerSupport)
+ (NSTimer *) md_scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void(^)())block repeats:(BOOL)repeats;
@end
