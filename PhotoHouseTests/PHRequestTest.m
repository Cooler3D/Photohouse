//
//  PHRequestTest.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/23/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+MD5.h"

#import "Json.h"

@interface PHRequestTest : XCTestCase

@end

@implementation PHRequestTest
{
    Json *json;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    json = [[Json alloc] init];
}

- (void)tearDown
{
    json = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTimeStamp
{
    NSString *timeStamp = [json getTimeStamp];
    XCTAssertTrue(timeStamp.length > 0, @"lenght == %@", timeStamp);
}

- (void) testToken
{
    NSString *password = @"1233";
    NSString *passwordMD5 = [password MD5];
    XCTAssertTrue([passwordMD5 isEqualToString:@"e034fb6b66aacc1d48f445ddfb08da98"], @"MD5 not equal");
    
    
    NSString *passwordMD5_MD5 = [passwordMD5 MD5];
    XCTAssertTrue([passwordMD5_MD5 isEqualToString:@"072dd1bd4bc18c97e20d9a87e6b67601"], @"MD5_MD5 not equal");
    
    
    
//    NSString *user_id = @"35";
//    NSString *timeStamp = @"1419318000";
//    NSString *token = [json getTokenWithUserID:user_id andTimeStamp:timeStamp andOldPasswordMD5:passwordMD5];
//    XCTAssertTrue([token isEqualToString:@"d58989ba92653be7467f0b65b7b0bbee"], @"token not equal; %@", token);
}

@end
