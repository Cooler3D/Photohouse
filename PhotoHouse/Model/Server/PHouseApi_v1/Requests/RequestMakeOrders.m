//
//  RequestMakeOrder.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/8/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "RequestMakeOrders.h"

#import "CoreDataProfile.h"

#import "PrintData.h"
#import "PrintImage.h"
#import "PropType.h"
#import "Template.h"


#import "PHRequestCommand.h"

@implementation RequestMakeOrders

- (id) initWithFirstName:(NSString*)firstName
             andLastName:(NSString*)lastName
                andPhone:(NSString*)phone
              andAddress:(NSString*)address
             withComment:(NSString*)text
    andPhotoRecordsArray:(NSArray*)cartArray
     andDeliveryPrintDta:(PrintData*)deliveryPrintData
{
    self = [super init];
    if (self)
    {
        [self createRequestWithFirstName:firstName
                             andLastName:lastName
                                andPhone:phone
                              andAddress:address
                             withComment:text
                    andPhotoRecordsArray:cartArray
                     andDeliveryPrintDta:deliveryPrintData];
    }
    return self;
}



- (void) createRequestWithFirstName:(NSString*)firstName
                        andLastName:(NSString*)lastName
                           andPhone:(NSString*)phone
                         andAddress:(NSString*)address
                        withComment:(NSString*)text
               andPhotoRecordsArray:(NSArray*)cartArray
                andDeliveryPrintDta:(PrintData*)deliveryPrintData
{
    
    
    
    
    NSString * timestamp = [self getTimeStamp];
    
    //NSLog(@"Size: %@", NSStringFromCGSize([[(PhotoRecord*)[[cartArray firstObject] firstObject] cropImage] size]) );
    
    
    
    
    
    NSMutableArray *dictionaryItems = [NSMutableArray array];
    for (PrintData *printData in cartArray) {
        NSArray *dictionaryImages = [self getDictionaryImagesWithPrintImages:printData.images];
        
        // Коментарии альбома
        NSString *albumComments = @"";
        /*if ([recordFirst.printData.albumSetting.comments length] > 0) {
            albumComments = [recordFirst.printData.albumSetting.comments stringByAddingPercentEscapesUsingEncoding:NSWindowsCP1251StringEncoding];
        }*/
        Template *userTemplate = printData.storeItem.propType.userTemplate;
        NSArray *albumLayouts = [userTemplate getUserLayoutsDictionaries];
        
        //
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%li", (long)printData.count],                  @"item_num",
                                    [NSString stringWithFormat:@"%li", (long)printData.purchaseID],             @"item_id",
                                    dictionaryImages,                                                           @"images",
                                    @"1",                                                                       @"image_proc",
                                    printData.props,                                                            @"props",
                                    albumComments,                                                              @"comment",
                                    albumLayouts,                                                               @"layouts",
                                    nil];
        [dictionaryItems addObject:dictionary];
    }
    
    
    
    
    // Add Delivery
    NSDictionary *deliveryDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%li", (long)deliveryPrintData.count],          @"item_num",
                                [NSString stringWithFormat:@"%li", (long)deliveryPrintData.purchaseID],     @"item_id",
                                @"",                                                                        @"images",
                                @"1",                                                                       @"image_proc",
                                deliveryPrintData.props,                                                    @"props",
                                @"",                                                                        @"comment",
                                nil];
    [dictionaryItems addObject:deliveryDictionary];


    
    // UserID
    CoreDataProfile *profile = [[CoreDataProfile alloc] init];
    NSString *profileID = [profile profileID];
    //
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [userDefaults objectForKey:APPLICATION_TOKEN];
    
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", lastName, firstName];
    
    // Формируем данные пользователя
    NSDictionary *dictionaryOther = [NSDictionary dictionaryWithObjectsAndKeys:
                                     fullName,                  @"full_name",
                                     address,                   @"address",
                                     phone,                     @"phone",
                                     text,                      @"description",
                                     @"1",                      @"status",
                                     profileID,                 @"user_id",
                                     nil];
    
    // Общий, куда всходит все
    NSDictionary *mainDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    ACT_ORDER,          @"act",
                                    dictionaryOther,    @"order_info",
                                    dictionaryItems,    @"items",
                                    timestamp,          @"time",
                                    deviceToken,        @"token",
                                    nil];
    
    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:mainDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonData as string:\n%@", jsonString);
    
    
    
    
    // Using base64DataFromString
    //NSString *stringFromBase64 = [self base64String:jsonString];
    //jsonString = @"";
    //NSLog(@"count: %i", [stringFromBase64 length]);
    
    
    // Кодируем данные
    NSMutableData *postData = [NSMutableData data];
    [postData appendData:[[NSString stringWithFormat:@"%@", jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //
    [self setURL:[NSURL URLWithString:SERVER_URL]];
    [self setValue:[self getDeviceName] forHTTPHeaderField:@"User-Agent"];
    [self setHTTPMethod:@"POST"];
    [self setHTTPBody:postData];
}





- (NSArray *) getDictionaryImagesWithPrintImages:(NSArray *)images
{
    NSMutableArray *dictionaryImages = [NSMutableArray array];
    
    for (PrintImage *printImage in images) {
        NSString *stringIndex = [NSString stringWithFormat:@"%lu", (unsigned long)printImage.index];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    printImage.uploadURL.absoluteString,    @"image",
                                    stringIndex,                            @"index",
                                    nil];
        [dictionaryImages addObject:dictionary];
    }
    
    return [dictionaryImages copy];
}

@end
