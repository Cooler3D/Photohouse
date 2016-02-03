//
//  GetBannersResponse.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/22/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "ResponseGetBanners.h"
#import "Banner.h"
#import "CoreDataStoreBanner.h"

NSString *const BANNERS_KEY = @"banners";
NSString *const INTERVAL_KEY = @"interval";

@implementation ResponseGetBanners
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
    NSArray *banners = [result objectForKey:BANNERS_KEY];
    [self readRanners:banners];
    _interval = [[result objectForKey:INTERVAL_KEY] integerValue];
}



-(void)saveBanners
{
    CoreDataStoreBanner *coreBanner = [[CoreDataStoreBanner alloc] init];
    [coreBanner saveBanners:[self bannersOnlyWithImages] andSwitchTimeInterval:_interval];
}



- (NSArray *) bannersOnlyWithImages
{
    NSMutableArray *array = [NSMutableArray array];
    for (Banner *banner in _banners) {
        if ([banner hasImage]) {
            [array addObject:banner];
        }
    }
    
    _banners = [NSArray arrayWithArray:array];
    return _banners;
}





- (void) readRanners:(NSArray *)banners {
    
    if ([banners isKindOfClass:[NSNull class]]) {
        return;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary *banner in banners) {
        Banner *b = [[Banner alloc] initWitDictionary:banner];
        [array addObject:b];
    }
    
    _banners = [array copy];
}

@end
