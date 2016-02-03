//
//  PhotoHouseServerApiTests.m
//  PhotoHouseServerApiTests
//
//  Created by Мартынов Дмитрий on 06/12/15.
//  Copyright © 2015 ___FULLUSERNAME___. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PHouseApi.h"

#import "ResponseAuth.h"
#import "ResponseRestorePass.h"
#import "ResponseFeedBack.h"

#import "NSString+MD5.h"

#import "CoreDataProfile.h"


typedef enum {
    AuthTypeSuccess,
    AuthTypeWrongPassword,
    AuthTypeRestorePass,
    AuthTypeRestoreWrongEmail,
    AuthTypeFeedBack,
    AuthTypeFeedBackAuth
} AuthType;


static CGFloat const TIMEOUT_AUTH = 20.f;



@interface PhotoHouseAuthTest : XCTestCase <PHouseApiDelegate>
@property (nonatomic) XCTestExpectation *expectation;
@property (nonatomic) AuthType authType;
@end




@implementation PhotoHouseAuthTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAuth {
    self.authType = AuthTypeSuccess;
    PHouseApi *api = [[PHouseApi alloc] init];
    NSString *password = @"123654";
    NSString *salt = [NSString stringWithFormat:@"%@%@", api.salt, password];
    NSString *pass = [salt MD5];
    [api authLogin:@"diman.mart@yandex.ru" andPasswordHash:pass andDelegate:self];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Auth"];
    self.expectation = expectation;
    [self waitForExpectationsWithTimeout:TIMEOUT_AUTH handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Timeout: %@", error);
        }
    }];
}

- (void)testAuthWrongPassword {
    self.authType = AuthTypeWrongPassword;
    PHouseApi *api = [[PHouseApi alloc] init];
    NSString *password = @"123654a";
    NSString *salt = [NSString stringWithFormat:@"%@%@", api.salt, password];
    NSString *pass = [salt MD5];
    [api authLogin:@"diman.mart@yandex.ru" andPasswordHash:pass andDelegate:self];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Auth"];
    self.expectation = expectation;
    [self waitForExpectationsWithTimeout:TIMEOUT_AUTH handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Timeout: %@", error);
        }
    }];
}


- (void) testRestorePass {
    self.authType = AuthTypeRestorePass;
    PHouseApi *api = [[PHouseApi alloc] init];
    [api restorePassWithEmail:@"diman.mart@yandex.ru" andDelegate:self];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Auth"];
    self.expectation = expectation;
    [self waitForExpectationsWithTimeout:TIMEOUT_AUTH handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Timeout: %@", error);
        }
    }];
}

- (void) testRestorePassUnregistredMail {
    self.authType = AuthTypeRestoreWrongEmail;
    PHouseApi *api = [[PHouseApi alloc] init];
    [api restorePassWithEmail:@"diman.mart11111@yandex.ru" andDelegate:self];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Auth"];
    self.expectation = expectation;
    [self waitForExpectationsWithTimeout:TIMEOUT_AUTH handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Timeout: %@", error);
        }
    }];
}


- (void) testFeedBack {
    self.authType = AuthTypeFeedBack;
    PHouseApi *api = [[PHouseApi alloc] init];
    [api feedbackType:FeedBackError andTitle:@"Ошибка" andMessage:@"Тестовое сообщение из UnitTest" andEmail:@"diman.mart@yandex.ru" andDelegate:self];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Auth"];
    self.expectation = expectation;
    [self waitForExpectationsWithTimeout:TIMEOUT_AUTH handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Timeout: %@", error);
        }
    }];
}

- (void) testFeedBackAuth {
    self.authType = AuthTypeFeedBackAuth;
    PHouseApi *api = [[PHouseApi alloc] init];
    NSString *password = @"123654";
    NSString *salt = [NSString stringWithFormat:@"%@%@", api.salt, password];
    NSString *pass = [salt MD5];
    [api authLogin:@"diman.mart@yandex.ru" andPasswordHash:pass andDelegate:self];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Auth"];
    self.expectation = expectation;
    [self waitForExpectationsWithTimeout:TIMEOUT_AUTH handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Timeout: %@", error);
        }
    }];
}


#pragma mark - PHouseApiDelegate
-(void)pHouseApi:(PHouseApi *)phApi didAuthReceiveData:(PHResponse *)response {
    // Проверяем ответ
    ResponseAuth *auth = (ResponseAuth*)response;
    XCTAssertTrue(auth.email.length > 0);
    XCTAssertTrue(auth.passwordHash.length > 0);
    XCTAssertTrue(auth.firstname.length > 0);
    XCTAssertTrue(auth.lastname.length > 0);
    XCTAssertTrue(auth.id_user.length > 0);
    XCTAssertTrue(auth.passwordHash.length > 0);
    XCTAssertTrue(auth.regdate.length > 0);
    
    // Проверяем сохраненность
    CoreDataProfile *profile = [[CoreDataProfile alloc] init];
    ResponseAuth *rAuth = [profile profile];
    XCTAssertTrue(rAuth.firstname.length > 0);
    XCTAssertTrue(rAuth.lastname.length > 0);
    XCTAssertTrue(rAuth.id_user.length > 0);
    XCTAssertTrue(rAuth.passwordHash.length > 0);
    XCTAssertTrue(rAuth.regdate.length > 0);

    if (self.authType == AuthTypeWrongPassword) {
        XCTFail(@"Need wrong password");
    } else if (self.authType != AuthTypeFeedBackAuth) {
        [self.expectation fulfill];
    } else {
        [phApi feedbackType:FeedBackError andTitle:@"UnitTest-Ошибка" andMessage:@"UnitTest message" andEmail:auth.email andDelegate:self];
    }
}

-(void)pHouseApi:(PHouseApi *)phApi didRestorePassData:(PHResponse *)response {
    if (self.authType == AuthTypeRestoreWrongEmail) {
#warning ToDo: Сюда приходят данные если e-mail пользователя не зарегистрирован, временно убранно, пока сервер не попрявят
//        XCTFail(@"Need Unregistred Email");
    }
    
    [self.expectation fulfill];
}

-(void)pHouseApi:(PHouseApi *)phApi didFailWithError:(NSError *)error {
    if (self.authType == AuthTypeSuccess || self.authType == AuthTypeRestorePass || self.authType == AuthTypeFeedBack || self.authType == AuthTypeFeedBackAuth) {
        XCTFail(@"Error: %@", error);
    }
    
    [self.expectation fulfill];
}

-(void)pHouseApi:(PHouseApi *)phApi didFeedBackData:(PHResponse *)response {
    [self.expectation fulfill];
}

@end
