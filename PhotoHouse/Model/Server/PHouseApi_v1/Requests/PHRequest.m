//
//  PHRequest.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/22/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHRequest.h"
#import "RequestGetBanners.h"

#import "AFnetworking.h"

#import "PHouseApiErrorCode.h"

#import "NSString+MD5.h"

#import "PHRequestCommand.h"


/// Блок успешного выполнения
typedef void(^CompleteRequestBlock)(NSData *);

/// Блок ошибки запроса
typedef void(^ErrorBlock)(NSError *);



@interface PHRequest () <NSURLConnectionDataDelegate, NSURLConnectionDelegate>
@property (copy, nonatomic) CompleteRequestBlock completeBlock;
@property (copy, nonatomic) ErrorBlock errorBlock;
@end



@implementation PHRequest

#pragma mark - Execute
- (void) executeResultBlock:(void(^)(NSData *responseData))resultBlock
                 errorBlock:(void(^)(NSError *error))errorBlock
{
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:self];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        NSString *responseString = [[NSString alloc] initWithData:[operation responseData] encoding:NSUTF8StringEncoding];
        NSLog(@"Execute.Responce: %@", responseString);
        if (resultBlock) {
            resultBlock([operation responseData]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Execute.Error: %@", error);
        NSError *err = [NSError errorWithDomain:@"Соединение с интернет недоступно" code:ErrorCodeTypeNotConnectToInternet userInfo:nil];
        if (errorBlock) {
            errorBlock(err);
        }
    }];
    
    [operation start];
}






- (void) executeResultBlock:(void (^)(NSData *responseData))resultBlock
        progressUploadBlock:(void (^)(CGFloat progress))progressBlock
                 errorBlock:(void (^)(NSError *error))errorBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //
    NSMutableURLRequest *requests = [[[AFHTTPRequestSerializer serializer] requestBySerializingRequest:self
                                                                                        withParameters:nil
                                                                                                 error:nil] mutableCopy];
    //[requests setTimeoutInterval:300];
    
    
    AFHTTPRequestOperation *requestOperation = [manager HTTPRequestOperationWithRequest:requests
                                                                                success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        //
        NSString *base64String = [[NSString alloc] initWithData:[operation responseData] encoding:NSUTF8StringEncoding];
        NSLog(@"UploadImage = %@", base64String);
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
        NSLog(@"Error: %@", error);
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
    }];
    [requestOperation start];
}




//-(void)executeUploadResultBlock:(void (^)(NSData *))resultBlock errorBlock:(void (^)(NSError *))errorBlock
//{
//    self.completeBlock = resultBlock;
//    self.errorBlock = errorBlock;
//    
//    //
//    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:self
//                                                                  delegate:self
//                                                          startImmediately:NO];
//    [connection start];
//}



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




#pragma mark - TimeStamp
- (NSString*)getTimeStamp
{
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



#pragma mark - Token UserID
- (NSString *) getTokenWithUserID:(NSString *)user_id andTimeStamp:(NSString *)timeStamp andOldPasswordMD5:(NSString *)password_md5
{
    NSString *passwordMD5_MD5 = [password_md5 MD5];
    NSString *token = [NSString stringWithFormat:@"%@%@%@", user_id, timeStamp, passwordMD5_MD5];
    NSString *tokenMD5 = [token MD5];
    return tokenMD5;
}


#pragma mark - Device Name
- (NSString *) getDeviceName//ForSize:(CGRect)deviceRect
{
    DeviceManager *manager = [[DeviceManager alloc] init];
    return [manager getDeviceName];
}
@end
