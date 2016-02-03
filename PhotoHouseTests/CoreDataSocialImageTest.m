//
//  CoreDataSocialImageTest.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/25/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CoreDataSocialImages.h"
#import "CoreDataCacheImage.h"

#import "PhotoRecord.h"

@interface CoreDataSocialImageTest : XCTestCase

@end

@implementation CoreDataSocialImageTest
{
    CoreDataSocialImages *social;
    CoreDataCacheImage *cookie;
    
    CacheStatusType cookieStatus;
}


- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    
    social = [[CoreDataSocialImages alloc] init];
    cookie = [[CoreDataCacheImage alloc] init];
    
    
    cookieStatus = [cookie isCacheStatus];
    if (cookieStatus == CacheClosed) {
        [cookie cacheSwitch:YES];
    }
    
    [social removeAllImages];
}


- (void)tearDown
{
    cookieStatus = [cookie isCacheStatus];
    if (cookieStatus == CacheClosed) {
        [cookie cacheSwitch:NO];
    }
    
    [social removeAllImages];
    social = nil;
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}





- (void)testSavePhotoRecord
{
    NSArray *socImages = [social getAllImgesWithLibraryType:ImportLibraryVKontkte];
    XCTAssertEqual(socImages.count, 0);
    
    NSArray *urls = [NSArray arrayWithObjects:@"http://albumBack", @"http://squareImage", @"http://horizontalImage", @"http://style_shildren", nil];
    
    PhotoRecord *record1 = [[PhotoRecord alloc] initWithSocialURl:[urls objectAtIndex:0] withImage:nil andImportLibrary:ImportLibraryVKontkte];
    [record1 setImage:[UIImage imageNamed:@"albumBack"]];
    
    PhotoRecord *record2 = [[PhotoRecord alloc] initWithSocialURl:[urls objectAtIndex:1] withImage:nil andImportLibrary:ImportLibraryVKontkte];
    [record2 setImage:[UIImage imageNamed:@"squareImage"]];
    
    PhotoRecord *record3 = [[PhotoRecord alloc] initWithSocialURl:[urls objectAtIndex:2] withImage:nil andImportLibrary:ImportLibraryVKontkte];
    [record3 setImage:[UIImage imageNamed:@"horizontalImage"]];
    
    PhotoRecord *record4 = [[PhotoRecord alloc] initWithSocialURl:[urls objectAtIndex:3] withImage:nil andImportLibrary:ImportLibraryVKontkte];
    [record4 setImage:[UIImage imageNamed:@"style_children"]];
    
    
    [social savePhotoRecord:record1];
    [social savePhotoRecord:record2];
    [social savePhotoRecord:record3];
    [social savePhotoRecord:record4];
    
    
    // Currect
    NSArray *result = [social getRecordWithNames:urls];
    XCTAssertTrue(result.count > 0);
    XCTAssertEqual(result.count, urls.count);
    
    for (id record in result) {
        XCTAssertTrue([record isKindOfClass:[PhotoRecord class]]);
        
        PhotoRecord *rec = (PhotoRecord*)record;
        XCTAssertTrue(rec.name.length > 0);
        XCTAssertNotNil(rec.image);
    }
}


- (void)testSaveImage
{
    
    NSString *url = @"url1";
    UIImage *image = [UIImage imageNamed:@"logo"];
    NSInteger library = 4;
    
    [social saveImage:image withURL:url andLibraryType:(ImportLibrary)(long)library];
    
    // Currect
    UIImage *getSavedImage = [social getImageWithURL:url];
    XCTAssertTrue(getSavedImage, @"Image is Empty");
}



- (void) testSaveAndGetEmpty {
    NSString *url = @"url1";
    UIImage *image = [UIImage imageNamed:@"logo"];
    NSInteger library = 4;
    
    [social saveImage:image withURL:url andLibraryType:(ImportLibrary)(long)library];
    
    
    // Empty
    UIImage *getSavedImage = [social getImageWithURL:@""];
    XCTAssertFalse(getSavedImage, @"Image Not Empty");
    
    // nil
    getSavedImage = [social getImageWithURL:nil];
    XCTAssertFalse(getSavedImage, @"Image Not Empty");
}



- (void) testArrayImagesWithLibrary {
    NSString *url1 = @"url1";
    NSString *url2 = @"url2";
    UIImage *image = [UIImage imageNamed:@"logo"];
    NSInteger library = 4;
    
    [social saveImage:image withURL:url1 andLibraryType:(ImportLibrary)library];
    [social saveImage:image withURL:url2 andLibraryType:(ImportLibrary)library];
    
    
    NSArray *images = [social getAllImgesWithLibraryType:(ImportLibrary)library];
    XCTAssertFalse(images.count == 0, @"Utuns is Empty");
    for (UIImage *img in images) {
        XCTAssertTrue(img, @"Image is Empty");
    }
    
    
    images = [social getAllImgesWithLibraryType:1];
    XCTAssertTrue(images.count == 0, @"Images %li", (long)images.count);
}



- (void) testRemoveAll {
    NSString *url1 = @"url1";
    NSString *url2 = @"url2";
    UIImage *image = [UIImage imageNamed:@"logo"];
    NSInteger library = 4;
    
    [social saveImage:image withURL:url1 andLibraryType:(ImportLibrary)library];
    [social saveImage:image withURL:url2 andLibraryType:(ImportLibrary)library];
    
    
    
    NSArray *images = [social getAllImgesWithLibraryType:(ImportLibrary)library];
    XCTAssertFalse(images.count == 0, @"Utuns is Empty");
    for (UIImage *img in images) {
        XCTAssertTrue(img, @"Image is Empty");
    }
    
    [social removeAllImages];
    
    images = [social getAllImgesWithLibraryType:(ImportLibrary)library];
    XCTAssertTrue(images.count == 0, @"Images not Empty");
}

@end
