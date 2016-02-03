//
//  ResponseUpdateTimes.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/6/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Banner.h"

#import "ResponseGetUpdateTimes.h"
#import "ResponseGetBanners.h"
#import "ResponseGetItems.h"
#import "ResponseAlbumV2.h"

#import "BundleDefault.h"

#import "AppDelegate.h"

#import "CoreDataStoreBanner.h"
#import "CoreDataStore.h"

@interface ResponseUpdateTimesTest : XCTestCase

@end

@implementation ResponseUpdateTimesTest
{
    ResponseGetUpdateTimes *responseGetUpdateTimes;
    BundleDefault *bundle;
}
- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    bundle = [[BundleDefault alloc] init];
    NSData *data = [bundle defaultDataWithBundleName:BundleDefaultTypeUpdateTimesTest];
    responseGetUpdateTimes = [[ResponseGetUpdateTimes alloc] initWitParseData:data];
}

- (void)tearDown
{
    CoreDataStore *store = [[CoreDataStore alloc] init];
    [store clearStory];
    
    CoreDataStoreBanner *coreBanner = [[CoreDataStoreBanner alloc] init];
    [coreBanner removeAllSavedBanners];
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testParseResponseFirstStart
{
    XCTAssertTrue(responseGetUpdateTimes.bannersNeedUpdate);
    XCTAssertTrue(responseGetUpdateTimes.getItemsNeedUpdate);
    XCTAssertTrue(responseGetUpdateTimes.getTemplatesNeedUpdate);
//    XCTAssertTrue(responseGetUpdateTimes.getDeliveriesNeedUpdate);
}

- (void) testSavedBannersAndDatesNil
{
    NSData *data = [bundle defaultDataWithBundleName:BundleDefaultTypeBanners];
    ResponseGetBanners *responseBanners;
    responseBanners = [[ResponseGetBanners alloc] initWitParseData:data];
    
    data = [bundle defaultDataWithBundleName:BundleDefaultTypeResponceUploadImageTest];
    responseGetUpdateTimes = [[ResponseGetUpdateTimes alloc] initWitParseData:data];
    
    XCTAssertTrue(responseGetUpdateTimes.bannersNeedUpdate);
}


- (void) testSavedBannersAndDatesCompare
{
    // Save Banners
    NSData *data = [bundle defaultDataWithBundleName:BundleDefaultTypeBanners];
    ResponseGetBanners *responseBanners;
    responseBanners = [[ResponseGetBanners alloc] initWitParseData:data];
    NSDate *responseTime = responseBanners.dateCmdResponse;
    
    NSMutableArray *createBanners = [NSMutableArray array];
    for (int i = 0; i < 2; i++) {
        Banner *banner = [[Banner alloc] initWithActionUrl:@"Banner" andImage:[UIImage imageNamed:@"logo"]];
        [createBanners addObject:banner];
    }
    CoreDataStoreBanner *coreBanner = [[CoreDataStoreBanner alloc] init];
    [coreBanner saveBanners:[createBanners copy] andSwitchTimeInterval:0 andTimeCommand:responseTime];
    
    
    // ResponseUpdate Time
    data = [bundle defaultDataWithBundleName:BundleDefaultTypeUpdateTimesTest];
    responseGetUpdateTimes = [[ResponseGetUpdateTimes alloc] initWitParseData:data];
    
    
    XCTAssertFalse(responseGetUpdateTimes.bannersNeedUpdate);
}


- (void) testSavedItemsAndDatesNil
{
    NSData *dataTempalate = [bundle defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2];
    ResponseAlbumV2 *responseTemplate = [[ResponseAlbumV2 alloc] initWitParseData:dataTempalate];
    NSDate *dateResponse = responseTemplate.dateCmdResponse;
    
    NSData *dataStore = [bundle defaultDataWithBundleName:BundleDefaultTypeAllItems];
    ResponseGetItems *responseStore;
    responseStore = [[ResponseGetItems alloc] initWitParseData:dataStore andTemplates:responseTemplate.oldTemplates andTemplateTime:dateResponse];
    
    NSData *data = [bundle defaultDataWithBundleName:BundleDefaultTypeUpdateTimesTest];
    responseGetUpdateTimes = [[ResponseGetUpdateTimes alloc] initWitParseData:data];
    
    XCTAssertFalse(responseGetUpdateTimes.getItemsNeedUpdate);
}


- (void) testSavedItemsAndDatesCompare
{
    NSData *dataTempalate = [bundle defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2];
    ResponseAlbumV2 *responseTemplate = [[ResponseAlbumV2 alloc] initWitParseData:dataTempalate];
    NSDate *dateResponse = responseTemplate.dateCmdResponse;
    
    NSData *dataStore = [bundle defaultDataWithBundleName:BundleDefaultTypeAllItems];
    ResponseGetItems *responseStore;
    responseStore = [[ResponseGetItems alloc] initWitParseData:dataStore andTemplates:responseTemplate.oldTemplates andTemplateTime:dateResponse];
    
    NSData *data = [bundle defaultDataWithBundleName:BundleDefaultTypeUpdateTimesTest];
    responseGetUpdateTimes = [[ResponseGetUpdateTimes alloc] initWitParseData:data];
    
    XCTAssertFalse(responseGetUpdateTimes.getItemsNeedUpdate);
}



- (void) testSavedTemplatesAndDatesNil
{
    NSData *dataTempalate = [bundle defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2];
    ResponseAlbumV2 *responseTemplate = [[ResponseAlbumV2 alloc] initWitParseData:dataTempalate];
    NSDate *dateResponse = responseTemplate.dateCmdResponse;
    
    NSData *dataStore = [bundle defaultDataWithBundleName:BundleDefaultTypeAllItems];
    ResponseGetItems *responseStore;
    responseStore = [[ResponseGetItems alloc] initWitParseData:dataStore andTemplates:responseTemplate.oldTemplates andTemplateTime:dateResponse];
    
    NSData *data = [bundle defaultDataWithBundleName:BundleDefaultTypeUpdateTimesTest];
    responseGetUpdateTimes = [[ResponseGetUpdateTimes alloc] initWitParseData:data];
    
    XCTAssertFalse(responseGetUpdateTimes.getTemplatesNeedUpdate);
}


- (void) testSavedTemplatesAndDatesCompare
{
    NSData *dataTempalate = [bundle defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2];
    ResponseAlbumV2 *responseTemplate = [[ResponseAlbumV2 alloc] initWitParseData:dataTempalate];
    NSDate *dateResponse = responseTemplate.dateCmdResponse;
    
    NSData *dataStore = [bundle defaultDataWithBundleName:BundleDefaultTypeAllItems];
    ResponseGetItems *responseStore;
    responseStore = [[ResponseGetItems alloc] initWitParseData:dataStore andTemplates:responseTemplate.oldTemplates andTemplateTime:dateResponse];
    
    NSData *data = [bundle defaultDataWithBundleName:BundleDefaultTypeUpdateTimesTest];
    responseGetUpdateTimes = [[ResponseGetUpdateTimes alloc] initWitParseData:data];
    
    XCTAssertFalse(responseGetUpdateTimes.getTemplatesNeedUpdate);
}



@end
