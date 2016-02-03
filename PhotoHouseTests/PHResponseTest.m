//
//  ResponseTest.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/25/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "BundleDefault.h"
#import "ResponseMakeOrdes.h"

@interface PHResponseTest : XCTestCase

@end

@implementation PHResponseTest
{
    BundleDefault *bundle;
}
- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    bundle = [[BundleDefault alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testReadResponseUploadImage
{
    NSData *data = [bundle defaultDataWithBundleName:BundleDefaultTypeResponceUploadImageTest];
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    XCTAssertNil(localError);
    
    NSString *code = [parsedObject objectForKey:@"code"];
//    NSString *codeDescr = [parsedObject objectForKey:@"code_desc"];
    XCTAssertFalse(code == 0);
//    XCTAssertTrue(codeDescr.length > 0);
    
    NSDictionary *result = [parsedObject objectForKey:@"result"];
    for (NSString *key in result.allKeys) {
        NSDictionary *itemDictionary = [result objectForKey:key];
        XCTAssertTrue(itemDictionary);
        
        if ([itemDictionary isKindOfClass:[NSDictionary class]]) {
            NSString *url = [itemDictionary objectForKey:@"url"];
            XCTAssertNotNil(url);
            XCTAssertFalse([url isEqualToString:@""]);
        
        }
    }
}


-(void)testResponseUpload
{
    NSData *data = [bundle defaultDataWithBundleName:BundleDefaultTypeResponceUploadImageTest];
    ResponseMakeOrdes *response = [[ResponseMakeOrdes alloc] initWitParseData:data];
    XCTAssertNil(response.error);
}

@end
