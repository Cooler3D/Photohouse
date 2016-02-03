//
//  RequestUploadImage.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/8/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "RequestUploadPrintImage.h"

#import "PrintImage.h"
#import "EditImageSetting.h"

#import "CoreDataProfile.h"
#import "CoreDataModel.h"

#import "NSDictionary+Rect.h"

#import "PHRequestCommand.h"
@implementation RequestUploadPrintImage
- (id) initUploadPrintImage:(PrintImage *)printImage
{
    self = [super initWithURL:[NSURL URLWithString:SERVER_URL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    if (self) {
//        [self createRequestWithPrintImage:printImage];
//        [self createCurlRequestWithPrintImage:printImage];
    }
    return self;
}




//- (void) createRequestWithPrintImage:(PrintImage *)printImage
//{
//    NSLog(@"Start PreUpload");
//    CGFloat startTime = CACurrentMediaTime();
//
//    NSData *imageData = printImage.imageLargeData;//UIImagePNGRepresentation(printImage.previewImage);
//    NSLog(@"image(bytes)JPG: %lu; Time: %f", (unsigned long)imageData.length, CACurrentMediaTime() - startTime);
//    
//    
//    NSString * timestamp = [self getTimeStamp];
//    
//    NSString *sig = @"";//[self createSigForUploadImageBase64:imageBase64 withTimeStamp:timestamp];
//    
//    EditImageSetting *setting = printImage.editedImageSetting;
//    NSDictionary *dictCropRect = [NSDictionary dictionaryFromCGRect:setting.cropRect];
//    
//    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
//    NSString *profileId = [coreProfile profileID];
//    
//    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    ACT_UPLOAD,                             @"act",
//                                    profileId,                              @"user_id",
//                                    @"1",                                   @"album_id",
//                                    dictCropRect,                           @"crop",
//                                    sig,                                    @"sig",
//                                    timestamp,                              @"time",
//                                    nil];
//    
//    
//    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
//    //NSLog(@"jsonData(bytes): %lu", (unsigned long)jsonString.length);
//    
//    
//    
//    
//    //Binary
//    /*NSString *binary = [NSString stringWithFormat:@"--with-binary\n%@\n--binary\n%@", jsonString, imageData];
//
//    // Кодируем данные
//    NSMutableData *postData = [NSMutableData data];
//    [postData appendData:[[NSString stringWithFormat:@"%@", binary] dataUsingEncoding:NSUTF8StringEncoding]];
//    //[postData appendData:[binary dataUsingEncoding:NSASCIIStringEncoding]];
//    //[postData appendData:jsonData2];
//    //[postData appendData:imageData];
//    
//    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
//    
//    //
//    [self setURL:[NSURL URLWithString:SERVER_URL]];
//    [self setValue:[self getDeviceName] forHTTPHeaderField:@"User-Agent"];
//    [self setHTTPMethod:@"POST"];
//    [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [self setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    [self setHTTPBody:postData];*/
//    //NSLog(@"Start Upload.data(bytes): %lu; Time: %f", (unsigned long)postData.length, CACurrentMediaTime() - startTime);
//    
//    
//    
//    
//    // -------- New ------------
//    NSMutableData *body = [NSMutableData data];
//    /*
//     --with-binary\n
//     {JSON}\n
//     --binary\n
//     binary data
//     */
//    //parameter1
//    [body appendData:[[NSString stringWithFormat:@"--with-binary\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"%@\n", jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"--binary\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:imageData];
//    
//     NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
//    
//    [self setURL:[NSURL URLWithString:SERVER_URL]];
//    [self setValue:[self getDeviceName] forHTTPHeaderField:@"User-Agent"];
//    [self setHTTPMethod:@"POST"];
//    [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [self setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    [self setHTTPBody:body];
//}


//- (void) createCurlRequestWithPrintImage:(PrintImage *)printImage
//{
//    NSLog(@"Start PreUpload");
//    CGFloat startTime = CACurrentMediaTime();
//    
//    NSData *imageData = printImage.imageLargeData;//UIImagePNGRepresentation(printImage.previewImage);
//    NSLog(@"image(bytes)JPG: %lu; Time: %f", (unsigned long)imageData.length, CACurrentMediaTime() - startTime);
//
//    
//    NSString *timeStamp = [self getTimeStamp];
//    
//    NSDictionary *uploadDict = @{@"act": @"upload_files",
//                                 @"time": timeStamp};
//    
//    
//    
//    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:uploadDict options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
//    NSLog(@"jsonData as string:\n%@", jsonString);
//    
//    
//    
//    NSMutableData *body = [NSMutableData data];
//    NSString *boundary =  @"----WebKitFormBoundarycC4YiaUFwM44F6rT";
//    
//    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
//    [self setValue:contentType forHTTPHeaderField:@"Content-Type"];
//    
//    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", @"json"] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[[NSString stringWithFormat:@"%@\r\n", jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    
//    if (imageData) {
//        [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"attach\"; filename=\"1.jpeg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[NSData dataWithData:imageData]];
//        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    }
//    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    
//    
////    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
//    
//    [self setURL:[NSURL URLWithString:SERVER_URL]];
//    [self setValue:[self getDeviceName] forHTTPHeaderField:@"User-Agent"];
//    [self setHTTPMethod:@"POST"];
////    [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [self setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[body length]]  forHTTPHeaderField:@"Content-Length"];
////    [self setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    [self setHTTPBody:body];
//}

@end
