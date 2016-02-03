//
//  ResponseGetDeliveries.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/24/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "ResponseGetDeliveries.h"
#import "DeliveryCity.h"
#import "DeliveryType.h"
#import "Payment.h"

#import "CoreDataDelivery.h"

#import "BundleDefault.h"


@interface ResponseGetDeliveries ()
@property (strong, nonatomic) NSString *selectCityUiName;
@end



@implementation ResponseGetDeliveries
-(id)initWitParseData:(NSData *)data
{
    self = [super init];
    if (self) {
        [self parse:data];
    }
    return self;
}

- (void) parse:(NSData *)response {
    // Check
    NSDictionary *result = [self hasErrorResponce:response];
    if (self.error != nil) {
        NSLog(@"error: %@", self.error);
        return;
    }
    
    // Read
    NSDictionary *deliveries = [result objectForKey:@"deliveries"];
    NSArray *cities = [deliveries objectForKey:@"cities"];
    NSDictionary *payments = [deliveries objectForKey:@"payments"];
    [self readCityes:cities andDictoinaryPayments:payments];
    
    
    // Read
//    NSString *statusResponse = [parsedObject objectForKey:ACT_GET_DELIVERIES];
//    if ([[statusResponse lowercaseString] isEqualToString:[@"OK" lowercaseString]])
//    {
//        //OK
//        NSArray *cities = [parsedObject objectForKey:@"cities"];
//        NSDictionary *payments = [parsedObject objectForKey:@"payments"];
//        [self readCityes:cities andDictoinaryPayments:payments];
//    }
//    else
//    {
//        // Error
//        // Есть ли сохраненные
//        if ([deliveryModel isSavedDelivery]) {
////            [self setError:[NSError errorWithDomain:@"Данные о доставке отсутствуют" code:ErrorCodeTypeInternalParse userInfo:nil]];
//        } else {
//            BundleDefault *bundleDefault = [[BundleDefault alloc] init];
//            NSData *data = [bundleDefault defaultDataWithBundleName:BundleDefaultTypeDelivery];
//            [self parseData:data];
//        }
//    }
}




- (void) readCityes:(NSArray *)cities andDictoinaryPayments:(NSDictionary *)payments
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary *city in cities) {
        DeliveryCity *cityDelivery = [[DeliveryCity alloc] initWithCityDictionary:city andDictionaryPayments:payments];
        [array addObject:cityDelivery];
    }
    
    // Save To CoreData
    CoreDataDelivery *core = [[CoreDataDelivery alloc] init];
    [core saveAllDelivery:[array copy]];
}






#pragma mark - Methods(Public)
/*- (NSArray *) getDeliveryForOrderWithDeliveryCity:(DeliveryCity *)deliveryCity
{
    DeliveryType *delType = [deliveryCity.types firstObject];
    PhotoPrintData *printData = [[PhotoPrintData alloc] init];
    [printData setPhotoObject:PhotoObjectDelivery];
    [printData setPropsDeliveryCityName:deliveryCity.name andTypeDelivery:delType.type andDeliveryCode:delType.code];
    
    PhotoRecord *record = [[PhotoRecord alloc] init];
    [record setPrintData:printData];
    
    NSArray *array = [NSArray arrayWithObject:record];
    return array;
}*/



- (DeliveryCity *) getDefaultDeliveryCity
{
    NSString *uiname        = @"Москва";
    NSString *code          = @"Moscow_Self";
    NSString *paymentType   = @"Оплата наличными при получении";
    DeliveryCity *deliveryCity = [self getDeliveryCityWithUICityName:uiname andCodeDelivery:code andPaymentUIName:paymentType];
    
    // Если значний нету, то формируем новое
    if (deliveryCity.types.count != 1 && [[[deliveryCity.types firstObject] payments] count] != 1) {
        uiname = [[self getAllCityUINames] firstObject];
        DeliveryCity *deliveryCity = [self getDeliveryCityWithUICityName:uiname];
        DeliveryType *deliveryType = [deliveryCity.types firstObject];
        deliveryCity = [self getDeliveryCityWithUICityName:@"Москва" andCodeDelivery:@"Moscow_Self"];//[self getDeliveryCityWithUICityName:uiname andCodeDelivery:deliveryType.code];
        Payment *payment = [deliveryType.payments firstObject];
        deliveryCity = [self getDeliveryCityWithUICityName:uiname andCodeDelivery:deliveryType.code andPaymentUIName:payment.uiname];
    }
    return deliveryCity;
}



-(NSArray *)getAllCityUINames
{
    CoreDataDelivery *coreDelivery = [[CoreDataDelivery alloc] init];
    return [coreDelivery getAllCityUINames];
}



- (DeliveryCity *)getDeliveryCityWithUICityName:(NSString *)uiname
{
    CoreDataDelivery *coreDelivery = [[CoreDataDelivery alloc] init];
    DeliveryCity *city = [coreDelivery getDeliveryCityWithUIName:uiname];
    return city;
}



- (DeliveryCity *) getDeliveryCityWithUICityName:(NSString *)uiname
                                 andCodeDelivery:(NSString *)code
{
    CoreDataDelivery *coreDelivery = [[CoreDataDelivery alloc] init];
    DeliveryCity *city = [coreDelivery getDeliveryCityWithUIName:uiname andDeliveryCode:code];
    return city;
}



-(DeliveryCity *)getDeliveryCityWithUICityName:(NSString *)uiname
                               andCodeDelivery:(NSString *)code
                              andPaymentUIName:(NSString *)paymentUIname
{
    CoreDataDelivery *coreDelivery = [[CoreDataDelivery alloc] init];
    DeliveryCity *city = [coreDelivery getDeliveryCityWithUICityName:uiname andCodeDelivery:code andPaymentUIName:paymentUIname];
    return city;
}



- (NSArray *)getAllPaymentForUICityName:(NSString *)uiname
                        andCodeDelivery:(NSString *)code
{
    CoreDataDelivery *coreDelivery = [[CoreDataDelivery alloc] init];
    return [coreDelivery getAllPaymentForUICityName:uiname andCodeDelivery:code];

}
@end
