//
//  RequestGetItems.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/23/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "RequestGetItems.h"

#import "PHRequestCommand.h"
@implementation RequestGetItems
//- (id) initItems
//{
//    self = [super init];
//    
//    NSString * timestamp = [self getTimeStamp];
//    
//    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    ACT_GET_ITEMS,      @"act",
//                                    timestamp,          @"time",
//                                    nil];
//    
//    
//    //
//    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
//    NSLog(@"jsonData as string:\n%@", jsonString);
//    
//    
//    // Кодируем данные
//    NSMutableData *postData = [NSMutableData data];
//    [postData appendData:[[NSString stringWithFormat:@"%@", jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    
//    [self setURL:[NSURL URLWithString:SERVER_URL]];
//    [self setValue:[self getDeviceName] forHTTPHeaderField:@"User-Agent"];
//    [self setHTTPMethod:@"POST"];
//    [self setHTTPBody:postData];
//    return self;
//
//}


-(id)initItems
{
    self = [super init];
    
    NSString * timestamp = [self getTimeStamp];
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        ACT_GET_ITEMS,      @"act",
                                        timestamp,          @"time",
                                        nil];
    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonData as string:\n%@", jsonString);
    
    
    NSString *boundary = @"YOUR_BOUNDARY_STRING";
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"json"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
    
//    UIImage *imageToPost = [UIImage imageNamed:@"squareImage"];
//    NSData *imageData = UIImageJPEGRepresentation(imageToPost, 0.5f);
//    if (imageData) {
//        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", @"attach"] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:imageData];
//        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//    }
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
