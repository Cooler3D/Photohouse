//
//  ResponseUpdateTime.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/6/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ResponseGetUpdateTime.h"
#import "ResponseGetBanners.h"
#import "ResponseGetItems.h"
#import "ResponseAlbumV2.h"

#import "BundleDefault.h"

#import "Banner.h"

#import "CoreDataStoreBanner.h"
#import "CoreDataStore.h"

@interface ResponseUpdateTimeTest : XCTestCase

@end

@implementation ResponseUpdateTimeTest
{
    ResponseGetUpdateTime *responseUpdateTime;
    BundleDefault *bundle;
    
    CoreDataStoreBanner *coreBanner;
    CoreDataStore *coreStore;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    bundle = [[BundleDefault alloc] init];
    coreBanner = [[CoreDataStoreBanner alloc] init];
    coreStore = [[CoreDataStore alloc] init];
}

- (void)tearDown
{
    [NSUserDefaults resetStandardUserDefaults];
    [coreBanner removeAllSavedBanners];
    [coreStore clearStory];
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBannersNotSaved
{
    NSData *updateTimeData = [bundle defaultDataWithBundleName:BundleDefaultTypeUpdateTimeTest];
    responseUpdateTime = [[ResponseGetUpdateTime alloc] initWitParseData:updateTimeData];
//    NSData *bannerTimeData = [bundle defaultDataWithBundleName:BundleDefaultTypeBanners];
//    ResponseGetBanners *responseGetBanners = [[ResponseGetBanners alloc] initWitParseData:bannerTimeData];
//    NSDate *bannerCommandTime = responseUpdateTime.serverCurrentTimeCommand;
//    
//    NSDate *updateTimeBanner = responseUpdateTime.updateTimeBanner;
    XCTAssertTrue(responseUpdateTime.bannersNeedUpdate);
}

- (void)testBannersSaved
{
    // Save ABnners
    NSData *bannerTimeData = [bundle defaultDataWithBundleName:BundleDefaultTypeBanners];
    ResponseGetBanners *responseGetBanners;
    responseGetBanners = [[ResponseGetBanners alloc] initWitParseData:bannerTimeData];
    
    NSMutableArray *createBanners = [NSMutableArray array];
    for (int i = 0; i < 2; i++) {
        Banner *banner = [[Banner alloc] initWithActionUrl:@"Banner" andImage:[UIImage imageNamed:@"logo"]];
        [createBanners addObject:banner];
    }
    [coreBanner saveBanners:[createBanners copy] andSwitchTimeInterval:0];
    
    // UpdateTime
    NSData *updateTimeData = [bundle defaultDataWithBundleName:BundleDefaultTypeUpdateTimeTest];
    responseUpdateTime = [[ResponseGetUpdateTime alloc] initWitParseData:updateTimeData];
   
    /** Внимание тест может не проходить, проверяйте значения "time" в GetBannersJSON и GetUpdateTimeJSON */
    XCTAssertFalse(responseUpdateTime.bannersNeedUpdate);
}


- (void)testGetItemsNotSaved
{
    [coreStore clearStory];
    NSData *updateTimeData = [bundle defaultDataWithBundleName:BundleDefaultTypeUpdateTimeTest];
    responseUpdateTime = [[ResponseGetUpdateTime alloc] initWitParseData:updateTimeData];
    
    XCTAssertTrue(responseUpdateTime.getItemsNeedUpdate);
}


- (void)testGetItemsSaved
{
    ResponseAlbumV2 *responseAlbumV2 = [[ResponseAlbumV2 alloc] initWitParseData:[bundle defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2]];
    
    NSData *dataItems = [bundle defaultDataWithBundleName:BundleDefaultTypeAllItems];
    ResponseGetItems *responseGetItems;
    responseGetItems = [[ResponseGetItems alloc] initWitParseData:dataItems andTemplates:responseAlbumV2.oldTemplates];
    
    
    NSData *updateTimeData = [bundle defaultDataWithBundleName:BundleDefaultTypeUpdateTimeTest];
    responseUpdateTime = [[ResponseGetUpdateTime alloc] initWitParseData:updateTimeData];
    
    XCTAssertFalse(responseUpdateTime.getItemsNeedUpdate);
}


- (void)testGetTemplateNotSaved
{
    [coreStore clearStory];
    NSData *updateTimeData = [bundle defaultDataWithBundleName:BundleDefaultTypeUpdateTimeTest];
    responseUpdateTime = [[ResponseGetUpdateTime alloc] initWitParseData:updateTimeData];
    
    XCTAssertTrue(responseUpdateTime.getTemplatesNeedUpdate);
}


- (void)testGetTemplateSaved
{
    ResponseAlbumV2 *responseAlbumV2 = [[ResponseAlbumV2 alloc] initWitParseData:[bundle defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2]];
    
    NSData *dataItems = [bundle defaultDataWithBundleName:BundleDefaultTypeAllItems];
    ResponseGetItems *responseGetItems;
    responseGetItems = [[ResponseGetItems alloc] initWitParseData:dataItems andTemplates:responseAlbumV2.oldTemplates];
    
    
    NSData *updateTimeData = [bundle defaultDataWithBundleName:BundleDefaultTypeUpdateTimeTest];
    responseUpdateTime = [[ResponseGetUpdateTime alloc] initWitParseData:updateTimeData];
    
    XCTAssertFalse(responseUpdateTime.getTemplatesNeedUpdate);
}



@end
