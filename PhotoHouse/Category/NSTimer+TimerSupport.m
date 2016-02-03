//
//  NSTimer+TimerSupport.m
//  TimerRepeat
//
//  Created by Мартынов Дмитрий on 14/01/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import "NSTimer+TimerSupport.h"

@implementation NSTimer (TimerSupport)

+ (NSTimer *) md_scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void(^)())block repeats:(BOOL)repeats
{
    return [self scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(md_blockInvoke:)
                                       userInfo:[block copy]
                                        repeats:repeats];
}

+ (void) md_blockInvoke:(NSTimer *)timer
{
    void (^block)() = timer.userInfo;
    if (block) {
        block();
    }
}
@end
