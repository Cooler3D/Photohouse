//
//  JsonRequestData.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 26/06/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import "Json.h"

#import "DeviceManager.h"

NSString *const SALT = @"wOwsAlTsoSaLt$o$aFeVERYsecure";


@implementation Json
@synthesize jsonDictionary = _jsonDictionary;
//@synthesize imageData = _imageData;



//-(void)updateImageData:(NSData *)imageDatas {
//    self.imageData = imageDatas;
//}


#pragma mark - TimeStamp
- (NSString*)getTimeStamp
{
    NSDate *past = [NSDate date];
    NSTimeInterval oldTime = [past timeIntervalSince1970];
    NSString *unixTime = [[NSString alloc] initWithFormat:@"%0.0f", oldTime];
    return unixTime;
    
    NSDateFormatter *objDateformat = [[NSDateFormatter alloc] init];
    [objDateformat setDateFormat:@"yyyy-MM-dd"];
    NSString    *strTime = [objDateformat stringFromDate:[NSDate date]];
    NSString    *strUTCTime = [self GetUTCDateTimeFromLocalTime:strTime];//You can pass your date but be carefull about your date format of NSDateFormatter.
    NSDate *objUTCDate  = [objDateformat dateFromString:strUTCTime];
    long long milliseconds = (long long)([objUTCDate timeIntervalSince1970] * 1000.0);
    
    NSString *strTimeStamp = [NSString stringWithFormat:@"%lld",milliseconds];
    //NSLog(@"The Timestamp is = %@",strTimeStamp);
    
    return strTimeStamp;
}


- (NSString *) GetUTCDateTimeFromLocalTime:(NSString *)IN_strLocalTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate  *objDate    = [dateFormatter dateFromString:IN_strLocalTime];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString *strDateTime   = [dateFormatter stringFromDate:objDate];
    return strDateTime;
}


#pragma mark - Device Name
- (NSString *) getDeviceName//ForSize:(CGRect)deviceRect
{
    DeviceManager *manager = [[DeviceManager alloc] init];
    return [manager getDeviceName];
}

@end
