//
//  DeviceManager.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/28/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "DeviceManager.h"

NSString *const IPHONE4 = @"ip4";
NSString *const IPHONE5 = @"ip5";
NSString *const IPHONE6 = @"ip6";
NSString *const IPHONE6P = @"ip6+";

NSString *const IPAD = @"ipad";
NSString *const IPAD_RETINA = @"ipad_retina";

@implementation DeviceManager
- (NSString *) getDeviceName//ForSize:(CGRect)deviceRect
{
    UIScreen *screen = [UIScreen mainScreen];
    //NSString *device = [self deviceForSize:[screen bounds]];
    CGRect deviceRect = [screen bounds];
    // IPhone
    CGSize const iphone4Size = CGSizeMake(320, 480);
    CGSize const iphone5Size = CGSizeMake(320, 568);
    CGSize const iphone6Size = CGSizeMake(375, 667);
    CGSize const iphone6pSize = CGSizeMake(540, 960);
    
    if (CGSizeEqualToSize(iphone4Size, deviceRect.size))    {  return IPHONE4;   }
    if (CGSizeEqualToSize(iphone5Size, deviceRect.size))    {  return IPHONE5;   }
    if (CGSizeEqualToSize(iphone6Size, deviceRect.size))    {  return IPHONE6;   }
    if (CGSizeEqualToSize(iphone6pSize, deviceRect.size))   {  return IPHONE6P;  }
    
    
    // IPad
    CGSize const ipadSize       = CGSizeMake(768, 1024);
    CGSize const ipadRetinaSize = CGSizeMake(1536, 2048);
    
    if (CGSizeEqualToSize(ipadSize, deviceRect.size))           {  return IPAD;   }
    if (CGSizeEqualToSize(ipadRetinaSize, deviceRect.size))     {  return IPAD_RETINA;   }
    
    
    return IPHONE6P;
}




- (BOOL) isIPhone4Device
{
    NSString *device = [self getDeviceName];
    if ([device isEqualToString:IPHONE4]) {
        return YES;
    } else {
        return NO;
    }
}


-(NSString *)getDeviceModelName
{
    NSString *deviceName = [self getDeviceName];
    NSRange range = NSMakeRange(2, 1);
    return [deviceName substringWithRange:range];
}

@end
