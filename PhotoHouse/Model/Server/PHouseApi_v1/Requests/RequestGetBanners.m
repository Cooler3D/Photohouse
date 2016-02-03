//
//  GetBannersRequest.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/22/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "RequestGetBanners.h"

#import "PHRequestCommand.h"
/*NSString *const IPHONE4 = @"ip4";
NSString *const IPHONE5 = @"ip5";
NSString *const IPHONE6 = @"ip6";
NSString *const IPHONE6P = @"ip6+";

NSString *const IPAD = @"ipad";
NSString *const IPAD_RETINA = @"ipad_retina";*/

@implementation RequestGetBanners


- (id) initBanners
{
    self = [super init];
    
    NSString * timestamp = [self getTimeStamp];
    
    //UIScreen *screen = [UIScreen mainScreen];
    NSString *device = [self getDeviceName];//[self deviceForSize:[screen bounds]];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    ACT_GET_BANNERS,    @"act",
                                    @"ios",             @"type",
                                    device,             @"screen",
                                    timestamp,          @"time",
                                    nil];
    
    
    //
    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
    //NSLog(@"jsonData as string:\n%@", jsonString);
    
    
    // Кодируем данные
    NSString *boundary = @"YOUR_BOUNDARY_STRING";
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"json"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[body length]];
    
    
    [self setURL:[NSURL URLWithString:SERVER_URL]];
    [self setValue:[self getDeviceName] forHTTPHeaderField:@"User-Agent"];
    [self setHTTPMethod:@"POST"];
    [self setValue:postLength forHTTPHeaderField:@"Content-Length"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [self setValue:contentType forHTTPHeaderField: @"Content-Type"];
    [self setHTTPBody:body];
    return self;
}



@end
