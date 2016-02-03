//В приоритете адрес указанный пользователем.
//Если пользователь защел в "Доставку", изменил адрес или телефон
//Вернулся обратно в корзину.
//Потом снова в доставку, требуется проверить сохранился ли адрес пользователя введенный вручную

#import <XCTest/XCTest.h>
#import "CoreDataProfile.h"

#import "ResponseAuth.h"
#import "ResponseRegistration.h"
#import "ResponseGetDeliveries.h"

#import "BundleDefault.h"

#import "DeliveryCity.h"
#import "DeliveryType.h"
#import "Payment.h"

#import "NSString+MD5.h"

#import "PHouseApi.h"

@interface CoreDataProfileTest : XCTestCase

@end

@implementation CoreDataProfileTest
{
    BundleDefault *bundleDefault;
    CoreDataProfile *profile;
    ResponseAuth *response;
    ResponseGetDeliveries *responseDeliveryes;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    bundleDefault = [[BundleDefault alloc] init];
    NSData *data = [bundleDefault defaultDataWithBundleName:BundleDefaultTypeResponceAuthTest];
    response = [[ResponseAuth alloc] initWitParseData:data];
    
    NSData *deliveryData = [bundleDefault defaultDataWithBundleName:BundleDefaultTypeDelivery];
    responseDeliveryes = [[ResponseGetDeliveries alloc] initWitParseData:deliveryData];
    
    profile = [[CoreDataProfile alloc] init];
    
}

- (void)tearDown
{
    [profile logount];
    profile             = nil;
    responseDeliveryes  = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSaveAddress
{
    [profile logount];
    NSData *data = [bundleDefault defaultDataWithBundleName:BundleDefaultTypeResponceAuthTest];
    PHouseApi *model = [[PHouseApi alloc] init];
    NSString *salt = [NSString stringWithFormat:@"%@%@", model.salt, @"123"];
    NSString *pass = [salt MD5];
    response = [[ResponseAuth alloc] initWitParseData:data andPasswordHash:pass];
    
    // Адрес сервера
    NSString *serverUserAddress = @"Москва, Тверская, 16";
    [profile addressCompareAndSave:serverUserAddress];
    
    // Пользовательский адрес
    NSString *userAddress = @"Санкт-Петербург, Невский проспект";
    [profile saveAddress:userAddress];
    
    // Заменился ли
    XCTAssertTrue([[profile getAddressProfile] isEqualToString:userAddress], @"Address not replace");
    
    
    // Снова обновляем и приходит адрес
    [profile addressCompareAndSave:serverUserAddress];
    NSLog(@"UserAddress: %@;", [profile getAddressProfile]);
    // ЗДолжен остаться userAddress
    XCTAssertTrue([[profile getAddressProfile] isEqualToString:userAddress], @"Address not replace. ServerAddress: %@; userAddress: %@", serverUserAddress, userAddress);
}


- (void)testSaveEmptyAddress
{
    NSString *serverUserAddress = nil;
    [profile saveAddress:serverUserAddress];
    
    
    NSString *userAddress = @"S-peterburg, nevskiy";
    [profile addressCompareAndSave:userAddress];
    
    XCTAssertTrue([[profile getAddressProfile] isEqualToString:userAddress], @"Address not replace");
    
    
    // Снова обновляем и приходит адрес
    [profile addressCompareAndSave:serverUserAddress];
    // ЗДолжен остаться userAddress
    XCTAssertTrue([[profile getAddressProfile] isEqualToString:userAddress], @"Address not replace. ServerAddress: %@; userAddress: %@", serverUserAddress, userAddress);
}



- (void) testSavePhone
{
    NSString *serverphone = @"8976532312";
    [profile savePhone:serverphone];
    
    
    NSString *newPhone = @"8976532314";
    [profile savePhone:newPhone];
    
    XCTAssertTrue([[profile getPhoneProfile] isEqualToString:newPhone], @"Phone not replace. Saved: %@; New: %@", [profile getPhoneProfile], newPhone);
    
    
    [profile phoneCompareAndSave:serverphone];
    XCTAssertTrue([[profile getPhoneProfile] isEqualToString:newPhone], @"Phone not replace. Saved: %@; New: %@", [profile getPhoneProfile], newPhone);
}


- (void) testSaveEmptyPhone
{
    NSString *serverphone = nil;
    [profile savePhone:serverphone];
    
    
    NSString *newPhone = @"8976532314";
    [profile savePhone:newPhone];
    
    XCTAssertTrue([[profile getPhoneProfile] isEqualToString:newPhone], @"Phone not replace. Saved: %@; New: %@", [profile getPhoneProfile], newPhone);
    
    //
    [profile phoneCompareAndSave:serverphone];
    XCTAssertTrue([[profile getPhoneProfile] isEqualToString:newPhone], @"Phone not replace. Saved: %@; New: %@", [profile getPhoneProfile], newPhone);

}



- (void) testSaveDeliveryToProfile
{
    DeliveryCity *deliveryCity = [responseDeliveryes getDefaultDeliveryCity];
    DeliveryType *deliveryType = [[[responseDeliveryes getDeliveryCityWithUICityName:deliveryCity.uiname] types] firstObject];
    Payment *payment = [[[[[responseDeliveryes getDeliveryCityWithUICityName:deliveryCity.uiname andCodeDelivery:deliveryType.code] types] firstObject] payments] firstObject];
    
    
    [profile saveDeliveryUiCityName:deliveryCity.uiname andDeliveryCode:deliveryType.code andUiPaymentName:payment.uiname];
    
    
    __block NSString *uiCity = deliveryCity.uiname;
    __block NSString *code = deliveryType.code;
    __block NSString *uiPayment = payment.uiname;
    [profile getDeliveryMemberWithBlock:^(NSString *uiCityName, NSString *deliveryCode, NSString *uiPaymentName)
    {
        XCTAssertTrue([uiCity isEqualToString:uiCityName], @"UI_City: %@ == %@", uiCity, uiCityName);
        XCTAssertTrue([code isEqualToString:deliveryCode], @"Code: %@ == %@", code, deliveryCode);
        XCTAssertTrue([uiPayment isEqualToString:uiPaymentName], @"UI_Payment: %@ == %@", uiPayment, uiPaymentName);
    }];
}



- (void) testSaveProfile
{
    NSString *firstName = @"testName";
    NSString *lastName = @"testLastName";
    NSString *email = @"test@test.ru";
//    NSString *password = @"test";
    NSString *user_id = @"15";
    NSString *regdate = @"23.01.2015";
    NSString *groupID = @"1";
    NSString *groupName = @"testgroupName";
    NSString *access = @"1";
    
    PHouseApi *model = [[PHouseApi alloc] init];
    NSString *salt = [NSString stringWithFormat:@"%@%@", model.salt, @"123"];
    NSString *pass = [salt MD5];
    
    ResponseAuth *responseAuth = [[ResponseAuth alloc] initWithIdUser:user_id
                                                       andPasswordHash:pass
                                                         andFirstName:firstName
                                                          andLastName:lastName
                                                             andEmail:email
                                                           andRegDate:regdate
                                                           andGroupID:groupID
                                                         andGroupName:groupName
                                                            andAccess:access];
    [profile saveProfile:responseAuth];
    
    responseAuth = nil;
    XCTAssertNil(responseAuth, @"Response Not nil");
    
    
    responseAuth = [profile profile];
    XCTAssertTrue([firstName isEqualToString:responseAuth.firstname], @" != %@", responseAuth.firstname);
    XCTAssertTrue([lastName isEqualToString:responseAuth.lastname], @" != %@", responseAuth.lastname);
    XCTAssertTrue([email isEqualToString:responseAuth.email], @" != %@", responseAuth.email);
//    XCTAssertTrue([[password MD5] isEqualToString:responseAuth.passwordMD5], @" != %@", responseAuth.passwordMD5);
    XCTAssertTrue([user_id isEqualToString:responseAuth.id_user], @" != %@", responseAuth.id_user);
    XCTAssertTrue([regdate isEqualToString:responseAuth.regdate], @" != %@", responseAuth.regdate);
    XCTAssertTrue([groupID isEqualToString:responseAuth.group_id], @" != %@", responseAuth.group_id);
    XCTAssertTrue([groupName isEqualToString:responseAuth.group_name], @" != %@", responseAuth.group_name);
    
    [profile logount];
}



- (void) testLogountProgileAndChectAddress
{
    [profile logount];
    
    NSString *user_id = [profile profileID];
    NSString *phone = [profile getPhoneProfile];
    NSString *address = [profile getAddressProfile];
    
    XCTAssertNil(phone, @"Phone == nil. Phone: %@", phone);
    XCTAssertNil(address, @"Address == nil. Address: %@", address);
    XCTAssertNil(user_id, @"user_id == nil. user_id: %@", user_id);
}



- (void) testRegistration
{
    [profile logount];
    
    NSString *user_id = [profile profileID];
    NSString *phone = [profile getPhoneProfile];
    NSString *address = [profile getAddressProfile];
    
    XCTAssertNil(phone, @"Phone == nil. Phone: %@", phone);
    XCTAssertNil(address, @"Address == nil. Address: %@", address);
    XCTAssertNil(user_id, @"user_id == nil. user_id: %@", user_id);
    
    NSData *data = [bundleDefault defaultDataWithBundleName:BundleDefaultTypeRegistrationTest];
    ResponseRegistration *responseRgistration;
    responseRgistration = [[ResponseRegistration alloc] initWitParseData:data];
    
    ResponseAuth *respAuth = [profile profile];
    XCTAssertTrue(respAuth.firstname, @" != %@", respAuth.firstname);
    XCTAssertTrue(respAuth.lastname, @" != %@", respAuth.lastname);
    XCTAssertTrue(respAuth.email, @" != %@", respAuth.email);
    XCTAssertTrue(respAuth.id_user, @" != %@", respAuth.id_user);
    XCTAssertTrue(respAuth.regdate, @" != %@", respAuth.regdate);
    XCTAssertTrue(respAuth.group_id, @" != %@", respAuth.group_id);
    XCTAssertTrue(respAuth.group_name, @" != %@", respAuth.group_name);
}



//- (void) testGetTimeCommandSave
//{
//    NSDate *commantDate = response.dateCmdResponse;
//    NSDate *savedDate = [profile time];
//    
//    XCTAssertTrue([commantDate isEqualToDate:savedDate]);
//}

@end
