//
//  BannerTest.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/27/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ResponseGetBanners.h"
#import "Banner.h"

#import "CoreDataStoreBanner.h"

#import "BundleDefault.h"

#import "PHouseApi.h"

static CGFloat const TIMEOUT_BANNER = 80.f;

@interface BannerTest : XCTestCase <PHouseApiDelegate>
@property (nonatomic) XCTestExpectation *expectation;
@end


@implementation BannerTest
{
    ResponseGetBanners *response;
    BundleDefault *bundleDefault;
    
    CoreDataStoreBanner *coreBanner;
    PHouseApi *api;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    coreBanner = [[CoreDataStoreBanner alloc] init];
    bundleDefault = [[BundleDefault alloc] init];
    api = [[PHouseApi alloc] init];
}

- (void)tearDown
{
    [coreBanner removeAllSavedBanners];
    coreBanner = nil;
    bundleDefault = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void)testResponseBanner
{
    NSData *data = [bundleDefault defaultDataWithBundleName:BundleDefaultTypeBanners];//[BannerResponse dataUsingEncoding:NSUTF8StringEncoding];
    response = [[ResponseGetBanners alloc] initWitParseData:data];
    
    //XCTAssertNil(response, @"response nil");
    XCTAssertFalse(response.banners.count == 0, @"Count != nil");
    
    for (Banner *banner in response.banners) {
        XCTAssertFalse([banner.imageUrl isEqualToString:@""], @"ImageNot nil");
        //XCTAssertFalse([banner.actionUrl isEqualToString:@""], @"ActionNot Nil"); // Может быть пустым
    }
}




- (void) testResponseBannerFromServer {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Banner"];
    self.expectation = expectation;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [api getBannersWithDelegate:self];
    });
    
    [self waitForExpectationsWithTimeout:TIMEOUT_BANNER handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout: %@", error);
        }
    }];
}


- (void) testCoreDataSavedBanner {
    NSMutableArray *createBanners = [NSMutableArray array];
    for (int i = 0; i < 2; i++) {
        Banner *banner = [[Banner alloc] initWithActionUrl:@"Banner" andImage:[UIImage imageNamed:@"logo"]];
        [createBanners addObject:banner];
    }
    [coreBanner saveBanners:[createBanners copy] andSwitchTimeInterval:0];
    
    NSArray *banners = [coreBanner getBannersSetInterval:0];
    XCTAssertFalse(banners.count == 0, @"Banners is Empty");
    for (id object in banners) {
        XCTAssertTrue([object isKindOfClass:[Banner class]], @"Do not Banner Class");
    }
}


- (void) testRemoveSavedBanners {
    NSMutableArray *createBanners = [NSMutableArray array];
    for (int i = 0; i < 2; i++) {
        Banner *banner = [[Banner alloc] initWithActionUrl:@"Banner" andImage:[UIImage imageNamed:@"logo"]];
        [createBanners addObject:banner];
    }
    [coreBanner saveBanners:[createBanners copy] andSwitchTimeInterval:0];
    [coreBanner removeAllSavedBanners];
    
    NSArray *banners = [coreBanner getBannersSetInterval:0];
    XCTAssertTrue(banners.count == 0, @"Banners is not Empty");
}


- (void) testHasBanners
{
    NSData *data = [bundleDefault defaultDataWithBundleName:BundleDefaultTypeBanners];
    response = [[ResponseGetBanners alloc] initWitParseData:data];
    
    NSMutableArray *createBanners = [NSMutableArray array];
    for (int i = 0; i < 2; i++) {
        Banner *banner = [[Banner alloc] initWithActionUrl:@"Banner" andImage:[UIImage imageNamed:@"logo"]];
        [createBanners addObject:banner];
    }
    [coreBanner saveBanners:[createBanners copy] andSwitchTimeInterval:0];
    
    
    XCTAssertTrue([coreBanner hasBanners]);
}


- (void) testHasBannerNotSave
{
    NSData *data = [bundleDefault defaultDataWithBundleName:BundleDefaultTypeBanners];
    response = [[ResponseGetBanners alloc] initWitParseData:data];
    
    XCTAssertFalse([coreBanner hasBanners]);
}


#pragma mark - PHouseApiDelegate
-(void)pHouseApi:(PHouseApi *)phApi didBannerReceiveData:(NSArray *)banners {
    XCTAssertFalse(banners.count == 0, @"Count != nil");
    
    for (Banner *banner in banners) {
        XCTAssertTrue(banner.image);
        XCTAssertFalse([banner.imageUrl isEqualToString:@""], @"ImageNot nil");
        XCTAssertFalse([banner.actionUrl isEqualToString:@""], @"ActionNot Nil"); // Может быть пустым
        XCTAssertFalse([banner.imageUrl isEqualToString:@""]);
    }

    /// Проверяем из CoreData, что сохранились
    NSInteger interval = 0;
    NSArray *saveBanners = [coreBanner getBannersSetInterval:&interval];
    XCTAssertTrue(interval > 0);
    
    for (Banner *banner in saveBanners) {
        XCTAssertTrue(banner.image);
        XCTAssertFalse([banner.imageUrl isEqualToString:@""], @"ImageNot nil");
        XCTAssertFalse([banner.actionUrl isEqualToString:@""], @"ActionNot Nil"); // Может быть пустым
        XCTAssertFalse([banner.imageUrl isEqualToString:@""]);
    }
    
    

    [self.expectation fulfill];
}

-(void)pHouseApi:(PHouseApi *)phApi didFailWithError:(NSError *)error {
    XCTFail(@"Error: %@", error);
    [self.expectation fulfill];
}


@end
