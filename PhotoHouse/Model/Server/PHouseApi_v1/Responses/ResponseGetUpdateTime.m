//
//  ResponseGetUpdateTime.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/6/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "ResponseGetUpdateTime.h"

#import "CoreDataStoreBanner.h"
#import "CoreDataStore.h"

#import "NSDate+ServerTime.h"

NSString *const BANNERS_SAVED_KEY         = @"BANNERS_SAVED_KEY";
NSString *const GET_ITEMS_SAVED_KEY       = @"GET_ITEMS_SAVED_KEY";
NSString *const GET_TEMPLATES_SAVED_KEY   = @"GET_TEMPLATES_SAVED_KEY";


@implementation ResponseGetUpdateTime
-(id)initWitParseData:(NSData *)data
{
    self = [super init];
    if (self) {
        [self parse:data];
    }
    return self;
}

- (void) parse:(NSData *)response {
    // Check
    NSDictionary *result = [self hasErrorResponce:response];
    if (self.error != nil) {
        NSLog(@"error: %@", self.error);
        return;
    }
    
    // Read
    NSString *commandGetBanners = [NSString stringWithFormat:@"%@", [result objectForKey:ACT_GET_BANNERS]];
    NSDate *dateBanners = [NSDate convertToDateWithServerTimer:commandGetBanners];
    [self compareBanners:dateBanners];
    
    NSString *commandGetItems = [NSString stringWithFormat:@"%@", [result objectForKey:ACT_GET_ITEMS]];
    NSDate *dateGetItems = [NSDate convertToDateWithServerTimer:commandGetItems];
    [self compareGetItems:dateGetItems];

    NSString *commandGetTemplate = [NSString stringWithFormat:@"%@", [result objectForKey:ACT_GET_ALBUM_TEMPLATE]];
    NSDate *dateGetTemplates = [NSDate convertToDateWithServerTimer:commandGetTemplate];
    [self compareGetTemplates:dateGetTemplates];
}


- (void) compareBanners:(NSDate *)commandDate
{
    NSDate *lastSavedDate = self.updateTimeBanner;
    
    CoreDataStoreBanner *coreBanner = [[CoreDataStoreBanner alloc] init];
    BOOL hasBanners = [coreBanner hasBanners];
    NSComparisonResult result = [commandDate compare:lastSavedDate];
    if (hasBanners && result == NSOrderedAscending) {
        // Есть баннеры и дата располагается по ворастанию (commandDate -> lastSavedDate)
        _bannersNeedUpdate = NO;
    } else {
        _bannersNeedUpdate = YES;
    }
}



- (void) compareGetItems:(NSDate *)commandDate
{
    NSDate *lastSavedDate = [self updateTimeGetItems];
    NSLog(@"\n");
    NSLog(@"Command.GetItems.Date: %@", lastSavedDate);
    NSLog(@"Server.UpdateTime.GetItems: %@", commandDate);
    
    CoreDataStore *coreStore = [[CoreDataStore alloc] init];
    BOOL hasStoreData = [coreStore hasStoreData];
    NSLog(@"CoreDateStore: %@", hasStoreData ? @"YES" : @"NO");
    NSComparisonResult result = [commandDate compare:lastSavedDate];
    if (hasStoreData && result == NSOrderedAscending) {
        // Есть баннеры и дата располагается по ворастанию (commandDate -> lastSavedDate)
        _getItemsNeedUpdate = NO;
    } else {
        _getItemsNeedUpdate = YES;
    }
}


- (void) compareGetTemplates:(NSDate *)commandDate
{
    NSDate *lastSavedDate = [self updateTimeGetItems];
    NSLog(@"\n");
    NSLog(@"Command.GetTemplates.Date: %@", lastSavedDate);
    NSLog(@"Server.UpdateTime.GetTemplates: %@", commandDate);
    
    CoreDataStore *coreStore = [[CoreDataStore alloc] init];
    BOOL hasStoreData = [coreStore hasStoreData];
    NSComparisonResult result = [commandDate compare:lastSavedDate];
    if (hasStoreData && result == NSOrderedAscending) {
        // Есть баннеры и дата располагается по ворастанию (commandDate -> lastSavedDate)
        _getTemplatesNeedUpdate = NO;
    } else {
        _getTemplatesNeedUpdate = YES;
    }
}



#pragma mark - Get Date
-(NSDate *)updateTimeBanner
{
    return [self getTimeWithKey:BANNERS_SAVED_KEY];
}


-(NSDate *)updateTimeGetItems
{
    return [self getTimeWithKey:GET_ITEMS_SAVED_KEY];
}


- (NSDate *) getTimeWithKey:(NSString *)key
{
    NSUserDefaults *userDefauls = [NSUserDefaults standardUserDefaults];
    NSDate *lastSavedDate = [userDefauls objectForKey:key];
    return lastSavedDate;
}



#pragma mark - Public
-(void)saveBannerTime:(NSInteger)bannerTime
{
    //
    NSString *stringTime = [NSString stringWithFormat:@"%li", (long)bannerTime];
    NSDate *updateTimeBanner = [NSDate convertToDateWithServerTimer:stringTime];
    
    NSUserDefaults *userDefauls = [NSUserDefaults standardUserDefaults];
    [userDefauls setObject:updateTimeBanner forKey:BANNERS_SAVED_KEY];
    [userDefauls synchronize];
}



- (void) savegetItemsTime:(NSInteger)getItemsTime
{
    //
    NSString *stringTime = [NSString stringWithFormat:@"%li", (long)getItemsTime];
    NSDate *updateTimeGetItems = [NSDate convertToDateWithServerTimer:stringTime];
//    NSLog(@"getItems.Date: %@", updateTimeGetItems);
    
    NSUserDefaults *userDefauls = [NSUserDefaults standardUserDefaults];
    [userDefauls setObject:updateTimeGetItems forKey:GET_ITEMS_SAVED_KEY];
    [userDefauls synchronize];
}

- (void) saveGetTemplatesTime:(NSInteger)getTemplatesTime
{
    //
    NSString *stringTime = [NSString stringWithFormat:@"%li", (long)getTemplatesTime];
    NSDate *updateTimeGetTemplates = [NSDate convertToDateWithServerTimer:stringTime];
//    NSLog(@"getTemplates.Date: %@", updateTimeGetTemplates);
    
    NSUserDefaults *userDefauls = [NSUserDefaults standardUserDefaults];
    [userDefauls setObject:updateTimeGetTemplates forKey:GET_TEMPLATES_SAVED_KEY];
    [userDefauls synchronize];
}



@end
