//
//  JsonOrder.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/26/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "JsonOrder.h"

#import "PrintData.h"
#import "PrintImage.h"

#import "Template.h"
#import "StoreItem.h"
#import "PropType.h"

#import "DeliveryCity.h"
#import "DeliveryType.h"
#import "Payment.h"

#import "CoreDataProfile.h"

#import "Acts.h"

#import "PHRequestCommand.h"


#import "NSDictionary+Rect.h"
#import "NSString+MD5.h"

@implementation JsonOrder
@synthesize jsonDictionary = _jsonDictionary;


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
        [self createJsonWithFirstName:firstName
                             andLastName:lastName
                                andPhone:phone
                              andAddress:address
                             withComment:text
                    andPhotoRecordsArray:cartArray
                     andDeliveryPrintDta:deliveryPrintData];
    }
    return self;
}


- (void) createJsonWithFirstName:(NSString*)firstName
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
                                    [NSString stringWithFormat:@"%li", (long)[printData price]],                @"price",
                                    nil];
        [dictionaryItems addObject:dictionary];
    }
    
    
    
    
    // Add Delivery
    NSInteger priceDelivery = [[deliveryPrintData.storeItem.delivery.types firstObject] cost];
    NSDictionary *deliveryDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%li", (long)deliveryPrintData.count],          @"item_num",
                                        [NSString stringWithFormat:@"%li", (long)deliveryPrintData.purchaseID],     @"item_id",
                                        @"",                                                                        @"images",
                                        @"1",                                                                       @"image_proc",
                                        deliveryPrintData.props,                                                    @"props",
                                        @"",                                                                        @"comment",
                                        [NSString stringWithFormat:@"%li", (long)priceDelivery],                    @"price",
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
    
    
    NSString *secure = [[NSString stringWithFormat:@"%@%@%@", profileID, profile.passowrdMD5, timestamp] MD5];
    
    // Общий, куда всходит все
//    NSDictionary *mainDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    ACT_ORDER,          @"act",
//                                    dictionaryOther,    @"order_info",
//                                    dictionaryItems,    @"items",
//                                    timestamp,          @"time",
//                                    deviceToken,        @"token",
//                                    secure,             @"secure",
//                                    nil];
    NSDictionary *mainDictionary = @{@"act" : ACT_ORDER,
                                       @"order_info" : dictionaryOther,
                                       @"items" : dictionaryItems,
                                       @"time" : timestamp,
                                       @"token" : deviceToken ? deviceToken : @"NULL",
                                       @"secure" : secure};
    _jsonDictionary = mainDictionary;
//    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:mainDictionary options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
//    NSLog(@"Json: %@", jsonString);
}


- (NSArray *) getDictionaryImagesWithPrintImages:(NSArray *)images
{
    NSMutableArray *dictionaryImages = [NSMutableArray array];
    
    for (PrintImage *printImage in images) {
        NSString *stringIndex = [NSString stringWithFormat:@"%lu", (unsigned long)printImage.index];
        
        NSDictionary *dictionary;
        if (printImage.isMergedImage) {
            dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    printImage.uploadURL.absoluteString,    @"image",
                                    stringIndex,                            @"index",
                                    nil];
        } else {
            NSDictionary *cropRect = [NSDictionary dictionaryFromCGRect:printImage.editedImageSetting.cropRect];
            dictionary = @{@"image"         : printImage.uploadURL.absoluteString,
                           @"index"         : stringIndex,
                           @"orientation"   : [NSString stringWithFormat:@"%li", (long)printImage.editedImageSetting.imageOrientation],
                           @"crop"          : cropRect};
        }
        
        [dictionaryImages addObject:dictionary];
    }
    
    return [dictionaryImages copy];
}

@end
