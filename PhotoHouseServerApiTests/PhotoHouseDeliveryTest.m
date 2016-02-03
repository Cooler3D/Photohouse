//
//  PhotoHouseDeliveryTest.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 06/12/15.
//  Copyright © 2015 Мартынов Дмитрий. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PHouseApi.h"

#import "ResponseGetDeliveries.h"

#import "DeliveryCity.h"
#import "DeliveryType.h"
#import "Payment.h"

static CGFloat const TIMEOUT_DELIVERY = 20.f;


@interface PhotoHouseDeliveryTest : XCTestCase <PHouseApiDelegate>
@property (nonatomic) XCTestExpectation *expectation;
@end



@implementation PhotoHouseDeliveryTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDelivery {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Delivery"];
    self.expectation = expectation;
    
    
    PHouseApi *api = [[PHouseApi alloc] init];
    [api getDeliveriesWithDelegate:nil orBlock:^(PHResponse *responce, NSError *error) {
        if (error) {
            [self pHouseApi:nil didFailWithError:error];
        } else {
            [self pHouseApi:nil didDeliveriesReceiveData:responce];
        }
    }];
    
    
    [self waitForExpectationsWithTimeout:TIMEOUT_DELIVERY handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Timeout: %@", error);
        }
    }];
}


#pragma mark - PHouseApiDelegate
-(void)pHouseApi:(PHouseApi *)phApi didDeliveriesReceiveData:(PHResponse *)response {
    ResponseGetDeliveries *delivery = (ResponseGetDeliveries*)response;
    NSArray *cityes = [delivery getAllCityUINames];
    XCTAssertTrue(cityes.count > 0);
    for (NSString *city in cityes) {
        // Типы Доставки
        NSArray *types = [[delivery getDeliveryCityWithUICityName:city] types];
        XCTAssertNotEqual(types.count, 0, @"DeliveryType's don't be empty");
        
        // Payment
        for (DeliveryType *deliveryType in types) {
            DeliveryCity *deliveryCity = [delivery getDeliveryCityWithUICityName:city andCodeDelivery:deliveryType.code];
            XCTAssertNotNil(deliveryCity, @"DeliveryCity, Don't be nil. city:%@; code: %@", deliveryCity.uiname, deliveryType.code);
            
            NSArray *payments = [[[deliveryCity types] firstObject] payments];
            XCTAssertNotEqual(payments.count, 0, @"Payment's don't be empty");
            // Тип отплаты
            for (Payment *payment in payments) {
                DeliveryCity *delivatyPayCity = [delivery getDeliveryCityWithUICityName:city andCodeDelivery:deliveryType.code andPaymentUIName:payment.uiname];
                XCTAssertNotNil(delivatyPayCity, @"Delivery Payment City == Nil, fix it");
            }
        }
    }

    [self.expectation fulfill];
}

-(void)pHouseApi:(PHouseApi *)phApi didFailWithError:(NSError *)error {
    XCTFail(@"Error: %@", error);
    [self.expectation fulfill];
}

@end
