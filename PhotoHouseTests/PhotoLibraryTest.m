//
//  PhotoLibraryTest.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 31/12/15.
//  Copyright © 2015 Мартынов Дмитрий. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MDPhotoLibrary.h"

static CGFloat const TIMEOUT_LIBARY = 60.f;

@interface PhotoLibraryTest : XCTestCase
@property (nonatomic) XCTestExpectation *expectation;

@property (nonatomic) MDPhotoLibrary *library;
@property (nonatomic) NSInteger assetsAllCount;
@property (nonatomic) NSMutableArray *assetParts;
@end


@implementation PhotoLibraryTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPhotoLibraryGetImageWithParams {
    
    XCTestExpectation *ex = [self expectationWithDescription:@"Library"];
    self.expectation = ex;
    
    MDPhotoLibrary *library = [[MDPhotoLibrary alloc] init];
    CGSize size = CGSizeMake(1600, 1200);
    UIImageOrientation orientation = UIImageOrientationUp;
    [library loadPhotoWithSize:size andOrientation:orientation withSuccessBlock:^(NSData *imageData, NSError *error) {
        XCTAssertNotNil(imageData);
        XCTAssertNil(error);
        
        UIImage *image = [UIImage imageWithData:imageData];
        XCTAssertTrue(image.size.width >= size.width);
        XCTAssertTrue(image.size.height >= size.height);
        XCTAssertTrue(image.imageOrientation == orientation);
        
        [self.expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:TIMEOUT_LIBARY handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout");
        }
    }];
}

- (void)testPhotoLibraryGetImagesWithParams {
#warning TODO: Fix [expectation fulfill]
    XCTestExpectation *ex = [self expectationWithDescription:@"Library"];
    self.expectation = ex;
    
    
    MDPhotoLibrary *library = [[MDPhotoLibrary alloc] init];
    NSInteger allOrientation = -1;
    CGSize size = CGSizeMake(1600, 1200);
    NSUInteger imageCount = 3;
    __weak PhotoLibraryTest *wSelf = self;
    [library loadPhotoDatasCount:imageCount withSize:size andOrientation:allOrientation withSuccessBlock:^(NSArray *imageDatas, NSError *error) {
        
        XCTAssertTrue(imageDatas.count == imageCount);
        XCTAssertNotNil(imageDatas);
        XCTAssertNil(error);
        
        for (NSData *imageData in imageDatas) {
            XCTAssertNotNil(imageData);
            XCTAssertNil(error);
            
            UIImage *image = [UIImage imageWithData:imageData];
            UIImage *result = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:image.imageOrientation];
            XCTAssertTrue(result.size.width >= size.width);
            XCTAssertTrue(result.size.height >= size.height);
            if (allOrientation != -1) {
                XCTAssertTrue(result.imageOrientation == allOrientation);
            }
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [wSelf.expectation fulfill];
        });
    }];
    
    [self waitForExpectationsWithTimeout:TIMEOUT_LIBARY handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout");
        }
        wSelf.expectation = nil;
    }];
}

- (void) testGetImageWithUrl {
    XCTestExpectation *ex = [self expectationWithDescription:@"Library"];
    self.expectation = ex;
    
    
    MDPhotoLibrary *library = [[MDPhotoLibrary alloc] init];
    [library loadPhotosAsynchronously:^(NSArray *assets, NSError *error) {
        ALAsset *asset = [assets lastObject];
        ALAssetRepresentation *rep = asset.defaultRepresentation;
        NSString *name = [rep.url absoluteString];
        
        // Загружаем по имени
        [library getAssetWithURL:name withResultBlock:^(NSData *imageData, UIImageOrientation orientation) {
            XCTAssertNotNil(imageData);
            
            UIImage *image = [UIImage imageWithData:imageData];
            XCTAssertTrue(image.size.width > 0);
            XCTAssertTrue(image.size.height > 0);
            [self.expectation fulfill];
            
        } failBlock:^(NSError *error) {
            XCTFail(@"Error: %@", error);
            [self.expectation fulfill];
        }];
    }];
    
    
    [self waitForExpectationsWithTimeout:TIMEOUT_LIBARY handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout");
        }
    }];
}

- (void) testSaveImageToPhotoLibrary {
    XCTestExpectation *ex = [self expectationWithDescription:@"Library"];
    self.expectation = ex;
    
    ///
    MDPhotoLibrary *library = [[MDPhotoLibrary alloc] init];
    UIImage *image = [UIImage imageNamed:@"run3"];
    [library saveImageToPhotoLibrary:image andImageOrientation:UIImageOrientationUp withSuccessBlock:^(NSString *assetURL) {
        XCTAssertNotNil(assetURL);
        XCTAssertTrue(assetURL.length > 0);
        [self.expectation fulfill];
        
    } failBlock:^(NSError *error) {
        XCTFail(@"Error: %@", error);
    }];

    
    [self waitForExpectationsWithTimeout:TIMEOUT_LIBARY handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout");
        }
    }];
}


- (void) testCompareAllImagesAndLoadingWithParts {
    XCTestExpectation *ex = [self expectationWithDescription:@"Library"];
    self.expectation = ex;
    
    MDPhotoLibrary *library = [[MDPhotoLibrary alloc] init];
    self.library = library;
    [library loadAllAssets:^(NSInteger assetCount) {
        XCTAssertTrue(assetCount > 0);
        self.assetParts = [NSMutableArray array];
        self.assetsAllCount = assetCount;
        
        [self loadNextPart];
        
    } andErrorBlock:^(NSError *error) {
        XCTFail(@"Error: %@", error);
        [self.expectation fulfill];
    }];
    
    
    [self waitForExpectationsWithTimeout:TIMEOUT_LIBARY handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout");
        }
    }];
}

- (void) loadNextPart {
    MDPhotoLibrary *library = self.library;
    [library loadPhotosAsynchronously:^(NSArray *assets, NSError *error) {
        //
        if (assets.count == 0) {
            // AllCompelete
            XCTAssertTrue(self.assetsAllCount >= self.assetParts.count);
            XCTAssertTrue(self.assetParts.count != 0);
            [self.expectation fulfill];
        } else {
            [self.assetParts addObjectsFromArray:assets];
            [self loadNextPart];
        }
        
        if (error) {
            XCTFail(@"Error: %@", error);
            [self.expectation fulfill];
        }
    }];
}

@end
