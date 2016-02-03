//
//  PHResponse.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/22/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHResponse.h"

#import "ResponseGetUpdateTime.h"

#import "NSDate+ServerTime.h"

#import "Fields.h"

@implementation PHResponse
- (id) initWitParseData:(NSData *)data {
    self = [super init];
    return self;
}


- (NSDictionary *) hasErrorResponce:(NSData *)parseData
{
    NSError *localError = nil;
    NSDictionary *parseObject = [NSJSONSerialization JSONObjectWithData:parseData
                                                                options:NSJSONReadingAllowFragments | NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves
                                                                  error:&localError];
    if (localError) {
        _error = localError;
        return nil;
    }
    
    // Read
    NSInteger code = [[parseObject objectForKey:@"code"] integerValue];
    if (code >= 0) {
        // Complete
        NSString *servTime = [parseObject objectForKey:@"time"];
        _serverCurrentTimeCommand = [NSDate convertToDateWithServerTimer:servTime];
        
        NSDictionary *result = [parseObject objectForKey:@"result"];
        [self saveActTimes:result andServerTime:servTime];
        return result;
    }
    else
    {
        // Error
        NSString *codeDescr = [parseObject objectForKey:@"code_desc"];
        _error = [NSError errorWithDomain:codeDescr code:code userInfo:@{@"ErrorKey":codeDescr}];
        return nil;
    }
}

- (void) saveActTimes:(NSDictionary *)dictionary andServerTime:(NSString *)serverTime
{
    NSString *actCommand = [dictionary objectForKey:FIELD_ACT];
    ResponseGetUpdateTime *responseUpdateTime = [[ResponseGetUpdateTime alloc] init];
    if ([actCommand isEqualToString:ACT_GET_BANNERS]) {
        NSInteger time = [serverTime integerValue];
        [responseUpdateTime saveBannerTime:time];
    }
    
    if ([actCommand isEqualToString:ACT_GET_ITEMS]) {
        NSInteger time = [serverTime integerValue];
        [responseUpdateTime savegetItemsTime:time];
    }
    
    if ([actCommand isEqualToString:ACT_GET_ALBUM_TEMPLATE]) {
        NSInteger time = [serverTime integerValue];
        [responseUpdateTime saveGetTemplatesTime:time];
    }

}
@end
