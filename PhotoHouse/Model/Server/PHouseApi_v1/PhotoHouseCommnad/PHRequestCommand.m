//
//  PHRequestCommand.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/26/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PHRequestCommand.h"
#import "Json.h"

#import "PHouseApiErrorCode.h"

#import "AFnetworking.h"



NSString * const APPLICATION_TOKEN = @"APPLICATION_TOKEN";


//NSString *const SERVER_URL_FOR_IMAGE = @"http://s01.photohouse.info/serv/";
NSString *const SERVER_URL = @"http://s01.photohouse.info/serv/";


/// Блок успешного выполнения
typedef void(^CompleteRequestBlock)(NSData *);

/// Блок ошибки запроса
typedef void(^ErrorBlock)(NSError *);



@interface PHRequestCommand () <NSURLConnectionDataDelegate, NSURLConnectionDelegate>
@property (copy, nonatomic) CompleteRequestBlock completeBlock;
@property (copy, nonatomic) ErrorBlock errorBlock;
@end


@implementation PHRequestCommand

- (void) executeCommnadWithJson:(Json *)jsonData
               andCompleteBlock:(void(^)(NSData *responseData))resultBlock
            progressUploadBlock:(void (^)(CGFloat progress))progressBlock
                     errorBlock:(void(^)(NSError *error))errorBlock
{
    self.completeBlock = resultBlock;
    self.errorBlock = errorBlock;
    
    NSMutableURLRequest *request = [self getRequestWithJson:jsonData];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                                  delegate:self
                                                          startImmediately:NO];
    [connection start];
    
    return;
    // AFNetworking
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //
    NSMutableURLRequest *requests = [[[AFHTTPRequestSerializer serializer] requestBySerializingRequest:request
                                                                                        withParameters:nil
                                                                                                 error:nil] mutableCopy];
    //[requests setTimeoutInterval:300];
    
    
    AFHTTPRequestOperation *requestOperation = [manager HTTPRequestOperationWithRequest:requests
                                                                                success:^(AFHTTPRequestOperation *operation, id responseObject)
                                                {
                                                    //
                                                    NSString *base64String = [[NSString alloc] initWithData:[operation responseData] encoding:NSUTF8StringEncoding];
                                                    NSString *act = [jsonData.jsonDictionary objectForKey:@"act"];
                                                    NSLog(@"ExecuteCommnad.Response: act: %@", [jsonData.jsonDictionary objectForKey:@"act"]);
                                                    if ([act isEqualToString:@"get_updates_time"]) {
                                                        NSLog(@"ExecuteCommnad.Response: %@", base64String);
                                                    }
                                                    //NSLog(@"Upload: Complete.Time: %f", CACurrentMediaTime() - startTime);
                                                    
                                                    if (![operation responseData]) {
                                                        // Данные не пришли
                                                        if (resultBlock) {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                errorBlock([NSError errorWithDomain:@"Данные не пришли от сервера" code:2 userInfo:nil]);
                                                            });
                                                        }
                                                    } else {
                                                        // Данные есть
                                                        if (resultBlock) {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                resultBlock([operation responseData]);
                                                            });
                                                        }
                                                    }
                                                    
                                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    NSLog(@"ExecuteCommnad (act: %@).Error: %@", [jsonData.jsonDictionary objectForKey:@"act"], error);
                                                    if (errorBlock) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            errorBlock(error);
                                                        });
                                                    }
                                                }];
    
    [requestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        double percentDone = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        if (progressBlock) {
            progressBlock(percentDone);
        }
//        NSLog(@"Progress: %f", percentDone);
    }];
    [requestOperation start];
}



#pragma mark - Methods
- (NSMutableURLRequest *) getRequestWithJson:(Json *)jsonData
{
    NSMutableData *body = [NSMutableData data];
    NSString *boundary =  @"----WebKitFormBoundarycC4YiaUFwM44F6rT";
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:jsonData.jsonDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", @"json"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    if (jsonData.imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"attach\"; filename=\"1.jpeg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:jsonData.imageData]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    //    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setURL:[NSURL URLWithString:SERVER_URL]];
    [request setValue:[jsonData getDeviceName] forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod:@"POST"];
    //    [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[body length]]  forHTTPHeaderField:@"Content-Length"];
    //    [self setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:body];
    return request;
}


#pragma mark - NSURLConnectionDataDelegate
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (self.completeBlock) {
        self.completeBlock(data);
    }
}



#pragma mark - NSURLConnectionDelegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.errorBlock) {
        self.errorBlock(error);
    }
}





@end
