/**
 Тест создан для класса ResponseGetDeliveries.h
 Если тесты не проходят, возможно в базе (CoreData) записаны страные данные без учета выбора типа оплаты
 */

#import <XCTest/XCTest.h>

#import "ResponseGetDeliveries.h"

#import "DeliveryCity.h"
#import "DeliveryType.h"
#import "Payment.h"

#import "Photorecord.h"

#import "BundleDefault.h"


@interface DeliveryTests : XCTestCase
@property (strong, nonatomic) ResponseGetDeliveries *response;
@end

@implementation DeliveryTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    BundleDefault *bundleDefault = [[BundleDefault alloc] init];
    NSData *data = [bundleDefault defaultDataWithBundleName:BundleDefaultTypeDelivery];
    _response = [[ResponseGetDeliveries alloc] initWitParseData:data];
}

- (void)tearDown
{
    _response = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


/** Проверяем возвращаются ли города, просто названия */
- (void)testAllCityes
{
    NSArray *cityes = [_response getAllCityUINames];
    XCTAssertNotEqual(cityes.count, 0, @"Cityes don't be empty");
}


/** Проверяем не пусты ли массивы с дипами доставки DeliveryType's */
- (void) testDeliveryTypesInCity
{
    NSArray *cityes = [_response getAllCityUINames];
    for (NSString *city in cityes) {
        DeliveryCity *deliveryCity = [_response getDeliveryCityWithUICityName:city];
        NSArray *types = [deliveryCity types];
        XCTAssertNotEqual(types.count, 0, @"DeliveryType's don't be empty");
    }
}


/** Проверяем возвращаются ли платежи для доставки Payment */
- (void) testPaymentInDeliveryTypes
{
    NSArray *cityes = [_response getAllCityUINames];
    for (NSString *city in cityes) {
        NSArray *types = [[_response getDeliveryCityWithUICityName:city] types];
        XCTAssertNotEqual(types.count, 0, @"DeliveryType's don't be empty");
        
        // Payment
        for (DeliveryType *deliveryType in types) {
            NSArray *payments = deliveryType.payments;
            XCTAssertNotEqual(payments.count, 0, @"Paymen's don't be empty");
        }
    }
}


/** Проверяем возвращаются ли платежи для доставки Payment, если делать запрос по коду(Code) */
- (void) testPaymentInDeliveryTypesCurrentCodes
{
    NSArray *cityes = [_response getAllCityUINames];
    for (NSString *city in cityes) {
        NSArray *types = [[_response getDeliveryCityWithUICityName:city] types];
        XCTAssertNotEqual(types.count, 0, @"DeliveryType's don't be empty");
        
        // Payment
        for (DeliveryType *deliveryType in types)
        {
            DeliveryCity *deliveryCity = [_response getDeliveryCityWithUICityName:city andCodeDelivery:deliveryType.code];
            XCTAssertNotNil(deliveryCity, @"DeliveryCity, Don't be nil. city:%@; code: %@", deliveryCity.uiname, deliveryType.code);
            
            NSArray *payments = [[[deliveryCity types] firstObject] payments];
            XCTAssertNotEqual(payments.count, 0, @"Payment's don't be empty");
        }
    }
}


- (void) testCurrentPaymentInDeliveryTypes
{
    // Имена городов
    NSArray *cityes = [_response getAllCityUINames];
    for (NSString *city in cityes)
    {
        // Типы Доставки
        NSArray *types = [[_response getDeliveryCityWithUICityName:city] types];
        XCTAssertNotEqual(types.count, 0, @"DeliveryType's don't be empty");
        
        // Payment
        for (DeliveryType *deliveryType in types)
        {
            DeliveryCity *deliveryCity = [_response getDeliveryCityWithUICityName:city andCodeDelivery:deliveryType.code];
            XCTAssertNotNil(deliveryCity, @"DeliveryCity, Don't be nil. city:%@; code: %@", deliveryCity.uiname, deliveryType.code);
            
            NSArray *payments = [[[deliveryCity types] firstObject] payments];
            XCTAssertNotEqual(payments.count, 0, @"Payment's don't be empty");
            // Тип отплаты
            for (Payment *payment in payments) {
                DeliveryCity *delivatyPayCity = [_response getDeliveryCityWithUICityName:city andCodeDelivery:deliveryType.code andPaymentUIName:payment.uiname];
                XCTAssertNotNil(delivatyPayCity, @"Delivery Payment City == Nil, fix it");
            }
        }
    }
}


- (void) testgetAllPayments
{
    // Имена городов
    NSArray *cityes = [_response getAllCityUINames];
    for (NSString *city in cityes)
    {
        // Типы Доставки
        NSArray *types = [[_response getDeliveryCityWithUICityName:city] types];
        XCTAssertNotEqual(types.count, 0, @"DeliveryType's don't be empty");
        
        // Payment
        for (DeliveryType *deliveryType in types)
        {
            DeliveryCity *deliveryCity = [_response getDeliveryCityWithUICityName:city andCodeDelivery:deliveryType.code];
            XCTAssertNotNil(deliveryCity, @"DeliveryCity, Don't be nil. city:%@; code: %@", deliveryCity.uiname, deliveryType.code);
            
            NSArray *paymentsList = [_response getAllPaymentForUICityName:city andCodeDelivery:deliveryType.code];
            XCTAssertNotEqual(paymentsList.count, 0, @"Payment's don't be empty");
        }
    }

}


- (void) testDefaultDeliveryCity
{
    DeliveryCity *deliveryCity = [_response getDefaultDeliveryCity];
    XCTAssertNotNil(deliveryCity, @"Default don't use");
}


/*- (void) testDeliveryOrder
{
    DeliveryCity *deliveryCity = [_response getDefaultDeliveryCity];
    NSArray *delivetyOrder = [_response getDeliveryForOrderWithDeliveryCity:deliveryCity];
    XCTAssertNotEqual(delivetyOrder.count, 0, @"Delivery for order is an empty");
}*/



- (void) testGetDeliveryProps
{
    DeliveryCity *deliveryCity = [_response getDefaultDeliveryCity];
    NSDictionary *dictonary = [deliveryCity getDeliveryProps];
    
    XCTAssertFalse(dictonary.allKeys.count == 0, @"Key Empty");
}

@end
