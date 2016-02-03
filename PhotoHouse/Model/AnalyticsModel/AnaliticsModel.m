//
//  AnaliticsModel.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 10/7/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "AnaliticsModel.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

NSString *const TRACKER_ID = @"UA-55506146-1";



typedef enum {
    ScreenNameStatusOpened,
    ScreenNameStatusClosed
} ScreenNameStatus;



@interface AnaliticsModel ()
@property (assign, nonatomic) ScreenNameStatus screenNameStatus;
@end




@implementation AnaliticsModel
+(AnaliticsModel*) sharedManager {
    static AnaliticsModel *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AnaliticsModel alloc] init];
        [instance initialization];
    });
    
    return instance;
}




- (void) initialization {
    // Status
    self.screenNameStatus = ScreenNameStatusClosed;
    
    
    // Init
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];//kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:TRACKER_ID];
}



#pragma mark - Methods
- (void) setScreenName:(NSString*)screenName {
    if (self.screenNameStatus == ScreenNameStatusOpened) {
        [self screenNameClear];
        self.screenNameStatus = ScreenNameStatusClosed;
    }
    
    
    /*id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:TRACKER_ID];
    
    
    // Send a screen view for "Home Screen".
    [tracker send:[[[GAIDictionaryBuilder createAppView] set:screenName
                                                      forKey:kGAIScreenName] build]];*/
    
    self.screenNameStatus = ScreenNameStatusOpened;
}


- (void) screenNameClear
{
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:TRACKER_ID];
    
    // Clear the screen name field when we're done.
    [tracker set:kGAIScreenName
           value:nil];

}


- (void) sendEventCategory:(NSString*)category andAction:(NSString*)action andLabel:(NSString*)label withValue:(NSNumber*)value {
    /*id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:TRACKER_ID];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                          action:action
                                                           label:label
                                                           value:value] build]];*/

}
@end
