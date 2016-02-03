//
//  MergedObjectsTest.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/19/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "UIImage+Crop.h"

#import "EllipseModel.h"

#import "CoreDataStore.h"
#import "StoreItem.h"
#import "PropType.h"

#import "PrintData.h"
#import "PrintImage.h"

#import "ResponseGetItems.h"
#import "BundleDefault.h"


@interface MergedObjectsTest : XCTestCase

@end



@implementation MergedObjectsTest
{
    CoreDataStore *coreStore;
    ResponseGetItems *response;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    BundleDefault *bundle = [[BundleDefault alloc] init];
    response = [[ResponseGetItems alloc] initWitParseData:[bundle defaultDataWithBundleName:BundleDefaultTypeAllItems]];
    
    coreStore = [[CoreDataStore alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - TShirt
- (void)testMergeTShirtSquareImage
{
    UIImage *previewImage = [UIImage imageNamed:@"squareImage"];
    //NSLog(@"previewImage.size: %@", NSStringFromCGSize(previewImage.size));
    
    
    
    // Футболка с вырезанной областью
    UIImage *imageTShirtTop = [UIImage imageNamed:@"T-shirt_top"];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:imageTShirtTop];
    
    
    
    
    
    
    
    // Размеры фона
    CGSize const tShirtSize = CGSizeMake(640, 586);
    
    // Позиция вырезенная в футболке
    CGRect const tShirtRectForImage = CGRectMake(190, 97, 252, 361);
    //CGRect const tShirtCrop = CGRectMake(95, 48, 126, 180);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(tShirtRectForImage) / tShirtSize.width,
                                          CGRectGetMinY(tShirtRectForImage) / tShirtSize.height,
                                          CGRectGetWidth(tShirtRectForImage)/ tShirtSize.width,
                                          CGRectGetHeight(tShirtRectForImage) / tShirtSize.height);
    
    
    CGRect const rectTshirt = CGRectMake(imageTShirtTop.size.width * CGRectGetMinX(persentRect),
                                         imageTShirtTop.size.height * CGRectGetMinY(persentRect),
                                         imageTShirtTop.size.width * CGRectGetWidth(persentRect),
                                         imageTShirtTop.size.height * CGRectGetHeight(persentRect));
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectTshirt) / CGRectGetHeight(rectTshirt);
    CGRect cropRect = [[UIImage alloc] sizeImage:previewImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:previewImage WithRect:cropRect];
    NSLog(@"cropImage: %@", NSStringFromCGSize(cropimage.size));
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectTshirt];
    
    
    
    // Проверяем соответствует ли пропорции
    XCTAssertEqual(CGRectGetHeight(cropRect) * CGRectGetWidth(rectTshirt) / CGRectGetHeight(rectTshirt), CGRectGetWidth(cropRect), @"Dont: %f", CGRectGetWidth(cropRect));
    
    
    
    // Задний слой
    // Обычная белая футболка
    UIImage *imageBack = [UIImage imageNamed:@"T-shirt_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageBack];
    
    /*NSLog(@"UpperImageView: %@", NSStringFromCGRect(shadowImageView.frame));
    NSLog(@"ImageView: %@", NSStringFromCGRect(imageView.frame));
    NSLog(@"BottomImageView: %@", NSStringFromCGRect(objectImageView.frame));*/
    
    
    // !!!!!
    // Здесь можно остановить и посмотреть скленное изображение
    // !!!!!
    UIImage *merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    XCTAssertNotNil(merge, @"Merge == nil");
}



- (void) testMergeTShirtHorizonailImage
{
    UIImage *previewImage = [UIImage imageNamed:@"horizontalImage"];
    //NSLog(@"previewImage.size: %@", NSStringFromCGSize(previewImage.size));
    
    
    
    // Футболка с вырезанной областью
    UIImage *imageTShirtTop = [UIImage imageNamed:@"T-shirt_top"];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:imageTShirtTop];
    
    
    
    
    
    
    
    // Размеры фона
    CGSize const tShirtSize = CGSizeMake(640, 586);
    
    // Позиция вырезенная в футболке
    CGRect const tShirtRectForImage = CGRectMake(190, 97, 252, 361);
    //CGRect const tShirtCrop = CGRectMake(95, 48, 126, 180);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(tShirtRectForImage) / tShirtSize.width,
                                          CGRectGetMinY(tShirtRectForImage) / tShirtSize.height,
                                          CGRectGetWidth(tShirtRectForImage)/ tShirtSize.width,
                                          CGRectGetHeight(tShirtRectForImage) / tShirtSize.height);
    
    
    CGRect const rectTshirt = CGRectMake(imageTShirtTop.size.width * CGRectGetMinX(persentRect),
                                         imageTShirtTop.size.height * CGRectGetMinY(persentRect),
                                         imageTShirtTop.size.width * CGRectGetWidth(persentRect),
                                         imageTShirtTop.size.height * CGRectGetHeight(persentRect));
    
    //NSLog(@"rectTShirt: %@", NSStringFromCGRect(rectTshirt));
    
    //CGRect imageRect = CGRectMake(68, 48.5f, 180, 180);// Final
    //[imageView setFrame:imageRect];
    
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectTshirt) / CGRectGetHeight(rectTshirt);
    CGRect cropRect = [[UIImage alloc] sizeImage:previewImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:previewImage WithRect:cropRect];
    //NSLog(@"cropImage: %@", NSStringFromCGSize(cropimage.size));
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectTshirt];
    
    
    // Проверяем соответствует ли пропорции
    XCTAssertEqual(CGRectGetHeight(cropRect) * CGRectGetWidth(rectTshirt) / CGRectGetHeight(rectTshirt), CGRectGetWidth(cropRect), @"Dont: %f", CGRectGetWidth(cropRect));
    
    
    // Задний слой
    // Обычная белая футболка
    UIImage *imageBack = [UIImage imageNamed:@"T-shirt_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageBack];
    
    //
    UIImage *merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    XCTAssertNotNil(merge, @"Merge == nil");
}



#pragma mark - Iphone 5
- (void)testMergeIPhone5SquareImage
{
    UIImage *previewImage = [UIImage imageNamed:@"squareImage"];
    //NSLog(@"previewImage.size: %@", NSStringFromCGSize(previewImage.size));
    
    
    
    // Чехол
    UIImage *imageIphone5Top = [UIImage imageNamed:@"Case5_top"];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:imageIphone5Top];
    
    
    
    
    
    
    
    // Размеры фона
    CGSize const tIphone5Size = CGSizeMake(258, 533);
    
    // Позиция вырезенная
    CGRect const tShirtRectForImage = CGRectMake(0, 0, tIphone5Size.width, tIphone5Size.height);
    //CGRect const tShirtCrop = CGRectMake(95, 48, 126, 180);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(tShirtRectForImage) / tIphone5Size.width,
                                          CGRectGetMinY(tShirtRectForImage) / tIphone5Size.height,
                                          CGRectGetWidth(tShirtRectForImage)/ tIphone5Size.width,
                                          CGRectGetHeight(tShirtRectForImage) / tIphone5Size.height);
    
    
    CGRect const rectIphone5 = CGRectMake(imageIphone5Top.size.width * CGRectGetMinX(persentRect),
                                         imageIphone5Top.size.height * CGRectGetMinY(persentRect),
                                         imageIphone5Top.size.width * CGRectGetWidth(persentRect),
                                         imageIphone5Top.size.height * CGRectGetHeight(persentRect));
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectIphone5) / CGRectGetHeight(rectIphone5);
    CGRect cropRect = [[UIImage alloc] sizeImage:previewImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:previewImage WithRect:cropRect];
    NSLog(@"cropImage: %@", NSStringFromCGSize(cropimage.size));
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectIphone5];
    
    
    // Задний слой
    // Обычная белая футболка
    UIImage *imageBack = [UIImage imageNamed:@"Case5_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageBack];
    
    /*NSLog(@"UpperImageView: %@", NSStringFromCGRect(shadowImageView.frame));
     NSLog(@"ImageView: %@", NSStringFromCGRect(imageView.frame));
     NSLog(@"BottomImageView: %@", NSStringFromCGRect(objectImageView.frame));*/
    
    
    // !!!!!
    // Здесь можно остановить и посмотреть скленное изображение
    // !!!!!
    UIImage *merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    XCTAssertNotNil(merge, @"Merge == nil");
}



- (void) testMergeIphone5HorizonailImage
{
    UIImage *previewImage = [UIImage imageNamed:@"horizontalImage"];
    //NSLog(@"previewImage.size: %@", NSStringFromCGSize(previewImage.size));
    
    
    
    // Футболка с вырезанной областью
    UIImage *imageTShirtTop = [UIImage imageNamed:@"Case5_top"];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:imageTShirtTop];
    
    
    
    
    
    
    
    // Размеры фона
    CGSize const tIphone5Size = CGSizeMake(258, 533);
    
    // Позиция вырезенная
    CGRect const tShirtRectForImage = CGRectMake(0, 0, tIphone5Size.width, tIphone5Size.height);
    //CGRect const tShirtCrop = CGRectMake(95, 48, 126, 180);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(tShirtRectForImage) / tIphone5Size.width,
                                          CGRectGetMinY(tShirtRectForImage) / tIphone5Size.height,
                                          CGRectGetWidth(tShirtRectForImage)/ tIphone5Size.width,
                                          CGRectGetHeight(tShirtRectForImage) / tIphone5Size.height);
    
    
    CGRect const rectTshirt = CGRectMake(imageTShirtTop.size.width * CGRectGetMinX(persentRect),
                                         imageTShirtTop.size.height * CGRectGetMinY(persentRect),
                                         imageTShirtTop.size.width * CGRectGetWidth(persentRect),
                                         imageTShirtTop.size.height * CGRectGetHeight(persentRect));
    
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectTshirt) / CGRectGetHeight(rectTshirt);
    CGRect cropRect = [[UIImage alloc] sizeImage:previewImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:previewImage WithRect:cropRect];
    NSLog(@"cropImage: %@", NSStringFromCGSize(cropimage.size));
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectTshirt];
    
    
    // Проверяем соответствует ли пропорции
    XCTAssertEqual(CGRectGetHeight(cropRect) * CGRectGetWidth(rectTshirt) / CGRectGetHeight(rectTshirt), CGRectGetWidth(cropRect), @"Dont: %f", CGRectGetWidth(cropRect));
    
    
    // Задний слой
    // Обычная белая футболка
    UIImage *imageBack = [UIImage imageNamed:@"Case5_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageBack];
    
    NSLog(@"UpperImageView: %@", NSStringFromCGRect(shadowImageView.frame));
    NSLog(@"ImageView: %@", NSStringFromCGRect(imageView.frame));
    NSLog(@"BottomImageView: %@", NSStringFromCGRect(objectImageView.frame));
    
    //
    UIImage *merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    XCTAssertNotNil(merge, @"Merge == nil");
}

#pragma mark - Iphone 4
- (void)testMergeIPhone4SquareImage
{
    UIImage *previewImage = [UIImage imageNamed:@"squareImage"];
    //NSLog(@"previewImage.size: %@", NSStringFromCGSize(previewImage.size));
    
    
    
    // Чехол
    UIImage *imageIphone5Top = [UIImage imageNamed:@"Case4_top"];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:imageIphone5Top];
    
    
    
    
    
    
    
    // Размеры фона
    CGSize const tIphone5Size = CGSizeMake(285, 545);
    
    // Позиция вырезенная
    CGRect const tShirtRectForImage = CGRectMake(0, 0, tIphone5Size.width, tIphone5Size.height);
    //CGRect const tShirtCrop = CGRectMake(95, 48, 126, 180);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(tShirtRectForImage) / tIphone5Size.width,
                                          CGRectGetMinY(tShirtRectForImage) / tIphone5Size.height,
                                          CGRectGetWidth(tShirtRectForImage)/ tIphone5Size.width,
                                          CGRectGetHeight(tShirtRectForImage) / tIphone5Size.height);
    
    
    CGRect const rectIphone5 = CGRectMake(imageIphone5Top.size.width * CGRectGetMinX(persentRect),
                                          imageIphone5Top.size.height * CGRectGetMinY(persentRect),
                                          imageIphone5Top.size.width * CGRectGetWidth(persentRect),
                                          imageIphone5Top.size.height * CGRectGetHeight(persentRect));
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectIphone5) / CGRectGetHeight(rectIphone5);
    CGRect cropRect = [[UIImage alloc] sizeImage:previewImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:previewImage WithRect:cropRect];
    //NSLog(@"cropImage: %@", NSStringFromCGSize(cropimage.size));
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectIphone5];
    
    
    
    // Задний слой
    // Обычная белая футболка
    UIImage *imageBack = [UIImage imageNamed:@"Case4_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageBack];
    
    /*NSLog(@"UpperImageView: %@", NSStringFromCGRect(shadowImageView.frame));
     NSLog(@"ImageView: %@", NSStringFromCGRect(imageView.frame));
     NSLog(@"BottomImageView: %@", NSStringFromCGRect(objectImageView.frame));*/
    
    
    // !!!!!
    // Здесь можно остановить и посмотреть скленное изображение
    // !!!!!
    UIImage *merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    XCTAssertNotNil(merge, @"Merge == nil");
}



- (void) testMergeIphone4HorizonailImage
{
    UIImage *previewImage = [UIImage imageNamed:@"horizontalImage"];
    //NSLog(@"previewImage.size: %@", NSStringFromCGSize(previewImage.size));
    
    
    
    // Футболка с вырезанной областью
    UIImage *imageTShirtTop = [UIImage imageNamed:@"Case4_top"];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:imageTShirtTop];
    
    
    
    
    
    
    
    // Размеры фона
    CGSize const tIphone5Size = CGSizeMake(285, 545);
    
    // Позиция вырезенная
    CGRect const tShirtRectForImage = CGRectMake(0, 0, tIphone5Size.width, tIphone5Size.height);
    //CGRect const tShirtCrop = CGRectMake(95, 48, 126, 180);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(tShirtRectForImage) / tIphone5Size.width,
                                          CGRectGetMinY(tShirtRectForImage) / tIphone5Size.height,
                                          CGRectGetWidth(tShirtRectForImage)/ tIphone5Size.width,
                                          CGRectGetHeight(tShirtRectForImage) / tIphone5Size.height);
    
    
    CGRect const rectTshirt = CGRectMake(imageTShirtTop.size.width * CGRectGetMinX(persentRect),
                                         imageTShirtTop.size.height * CGRectGetMinY(persentRect),
                                         imageTShirtTop.size.width * CGRectGetWidth(persentRect),
                                         imageTShirtTop.size.height * CGRectGetHeight(persentRect));
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectTshirt) / CGRectGetHeight(rectTshirt);
    CGRect cropRect = [[UIImage alloc] sizeImage:previewImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:previewImage WithRect:cropRect];
    NSLog(@"cropImage: %@", NSStringFromCGSize(cropimage.size));
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectTshirt];
    
    
    // Задний слой
    // Обычная белая футболка
    UIImage *imageBack = [UIImage imageNamed:@"Case4_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageBack];
    
    NSLog(@"UpperImageView: %@", NSStringFromCGRect(shadowImageView.frame));
    NSLog(@"ImageView: %@", NSStringFromCGRect(imageView.frame));
    NSLog(@"BottomImageView: %@", NSStringFromCGRect(objectImageView.frame));
    
    //
    UIImage *merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    XCTAssertNotNil(merge, @"Merge == nil");
}

#pragma mark - Canvas
- (void)testMergeCanvasSquareImage
{
    UIImage *previewImage = [UIImage imageNamed:@"squareImage"];
    //NSLog(@"previewImage.size: %@", NSStringFromCGSize(previewImage.size));
    
    
    
    // Футболка с вырезанной областью
    UIImage *imageCanvasTop = [UIImage imageNamed:@"canvas_top"];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:imageCanvasTop];
    
    
    
    
    
    
    
    // Размеры фона
    CGSize const canvasSize = CGSizeMake(640, 586);
    
    // Позиция вырезенная в футболке
    CGRect const canvasRectForImage = CGRectMake(121, 18, 394, 557);
    //CGRect const tShirtCrop = CGRectMake(95, 48, 126, 180);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(canvasRectForImage) / canvasSize.width,
                                          CGRectGetMinY(canvasRectForImage) / canvasSize.height,
                                          CGRectGetWidth(canvasRectForImage)/ canvasSize.width,
                                          CGRectGetHeight(canvasRectForImage) / canvasSize.height);
    
    
    CGRect const rectCanvas = CGRectMake(imageCanvasTop.size.width * CGRectGetMinX(persentRect),
                                         imageCanvasTop.size.height * CGRectGetMinY(persentRect),
                                         imageCanvasTop.size.width * CGRectGetWidth(persentRect),
                                         imageCanvasTop.size.height * CGRectGetHeight(persentRect));
    
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectCanvas) / CGRectGetHeight(rectCanvas);
    CGRect cropRect = [[UIImage alloc] sizeImage:previewImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:previewImage WithRect:cropRect];
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectCanvas];
    
    
    // Задний слой
    // Обычная белая футболка
    UIImage *imageBack = [UIImage imageNamed:@"canvas_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageBack];
    
    //
    UIImage *merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    XCTAssertNotNil(merge, @"Merge == nil");
}



- (void) testMergeCanvasHorizonailImage
{
    UIImage *previewImage = [UIImage imageNamed:@"horizontalImage"];
    //NSLog(@"previewImage.size: %@", NSStringFromCGSize(previewImage.size));
    
    
    
    // Футболка с вырезанной областью
    UIImage *imageCanvasTop = [UIImage imageNamed:@"canvas_top"];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:imageCanvasTop];
    
    
    
    
    
    
    
    // Размеры фона
    CGSize const canvasSize = CGSizeMake(640, 586);
    
    // Позиция вырезенная в футболке
    CGRect const canvasRectForImage = CGRectMake(121, 18, 394, 557);
    //CGRect const tShirtCrop = CGRectMake(95, 48, 126, 180);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(canvasRectForImage) / canvasSize.width,
                                          CGRectGetMinY(canvasRectForImage) / canvasSize.height,
                                          CGRectGetWidth(canvasRectForImage)/ canvasSize.width,
                                          CGRectGetHeight(canvasRectForImage) / canvasSize.height);
    
    
    CGRect const rectCanvas = CGRectMake(imageCanvasTop.size.width * CGRectGetMinX(persentRect),
                                         imageCanvasTop.size.height * CGRectGetMinY(persentRect),
                                         imageCanvasTop.size.width * CGRectGetWidth(persentRect),
                                         imageCanvasTop.size.height * CGRectGetHeight(persentRect));
   
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectCanvas) / CGRectGetHeight(rectCanvas);
    CGRect cropRect = [[UIImage alloc] sizeImage:previewImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:previewImage WithRect:cropRect];
    NSLog(@"cropImage: %@", NSStringFromCGSize(cropimage.size));
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectCanvas];
    
    
    // Задний слой
    // Обычная белая футболка
    UIImage *imageBack = [UIImage imageNamed:@"canvas_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageBack];
    
    //
    UIImage *merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    XCTAssertNotNil(merge, @"Merge == nil");
}

#pragma mark - Magnit Love
- (void)testMergeMagnitSquareImage
{
    UIImage *previewImage = [UIImage imageNamed:@"squareImage"];
    //NSLog(@"previewImage.size: %@", NSStringFromCGSize(previewImage.size));
    
    
    
    UIImage *imageMagnitTop = [UIImage imageNamed:@"magnet_heart_top"];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:imageMagnitTop];
    
    
    
    
    
    
    
    // Размеры фона
    CGSize const magnitSize = CGSizeMake(640, 586);
    
    // Позиция вырезенная в футболке
    CGRect const magnitRectForImage = CGRectMake(43, 43, 550, 475);
    //CGRect const tShirtCrop = CGRectMake(95, 48, 126, 180);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(magnitRectForImage) / magnitSize.width,
                                          CGRectGetMinY(magnitRectForImage) / magnitSize.height,
                                          CGRectGetWidth(magnitRectForImage)/ magnitSize.width,
                                          CGRectGetHeight(magnitRectForImage) / magnitSize.height);
    
    
    CGRect const rectCanvas = CGRectMake(imageMagnitTop.size.width * CGRectGetMinX(persentRect),
                                         imageMagnitTop.size.height * CGRectGetMinY(persentRect),
                                         imageMagnitTop.size.width * CGRectGetWidth(persentRect),
                                         imageMagnitTop.size.height * CGRectGetHeight(persentRect));
    
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectCanvas) / CGRectGetHeight(rectCanvas);
    CGRect cropRect = [[UIImage alloc] sizeImage:previewImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:previewImage WithRect:cropRect];
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectCanvas];
    
    
    // Задний слой
    // Обычная белая футболка
    UIImage *imageBack = [UIImage imageNamed:@"magnet_heart_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageBack];
    
    //
    UIImage *merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    XCTAssertNotNil(merge, @"Merge == nil");
}



- (void) testMergeMagnitHorizonailImage
{
    UIImage *previewImage = [UIImage imageNamed:@"horizontalImage"];
    //NSLog(@"previewImage.size: %@", NSStringFromCGSize(previewImage.size));
    
    
    UIImage *imageMagnitTop = [UIImage imageNamed:@"magnet_heart_top"];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:imageMagnitTop];
    
    
    
    
    
    
    
    // Размеры фона
    CGSize const magnitSize = CGSizeMake(640, 586);
    
    // Позиция вырезенная в футболке
    CGRect const magnitRectForImage = CGRectMake(43, 43, 550, 475);
    //CGRect const tShirtCrop = CGRectMake(95, 48, 126, 180);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(magnitRectForImage) / magnitSize.width,
                                          CGRectGetMinY(magnitRectForImage) / magnitSize.height,
                                          CGRectGetWidth(magnitRectForImage)/ magnitSize.width,
                                          CGRectGetHeight(magnitRectForImage) / magnitSize.height);
    
    
    CGRect const rectCanvas = CGRectMake(imageMagnitTop.size.width * CGRectGetMinX(persentRect),
                                         imageMagnitTop.size.height * CGRectGetMinY(persentRect),
                                         imageMagnitTop.size.width * CGRectGetWidth(persentRect),
                                         imageMagnitTop.size.height * CGRectGetHeight(persentRect));
   
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectCanvas) / CGRectGetHeight(rectCanvas);
    CGRect cropRect = [[UIImage alloc] sizeImage:previewImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:previewImage WithRect:cropRect];
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectCanvas];
    
    
    // Задний слой
    // Обычная белая футболка
    UIImage *imageBack = [UIImage imageNamed:@"magnet_heart_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageBack];
    
    
    //
    UIImage *merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    XCTAssertNotNil(merge, @"Merge == nil");
}




#pragma mark - Magnit Collage
- (void)testMergeMagnitCollageSquareImage
{
    NSString *const categoryName = @"Чехлы и магниты";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    
    PrintData *printData;
    for (StoreItem *store in storeItems) {
        if ([store.purchaseID isEqualToString:@"14"] && [store.propType.name isEqualToString:@"collage"]) {
            printData = [[PrintData alloc] initWithStoreItem:store andUniqueNum:0];
        }
    }
    
    UIImage *previewImage = [UIImage imageNamed:@"squareImage"];
    PrintImage *image1 = [[PrintImage alloc] initWithPreviewImage:previewImage withName:@"image1" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image2 = [[PrintImage alloc] initWithPreviewImage:previewImage withName:@"image2" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image3 = [[PrintImage alloc] initWithPreviewImage:previewImage withName:@"image3" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image4 = [[PrintImage alloc] initWithPreviewImage:previewImage withName:@"image4" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObjects:image1, image2, image3, image4, nil]];
    [printData createAndAddMergedImageWithPrintImage:nil];
    
    // Тест не проходит, т.к магнит-коллаж отключен из магазина
//    XCTAssertTrue(printData.mergedImages.count == 1, @"Merge: %lu", (unsigned long)printData.mergedImages.count);
}



- (void) testMergeMagnitCollageHorizonailImage
{
    NSString *const categoryName = @"Чехлы и магниты";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    
    PrintData *printData;
    for (StoreItem *store in storeItems) {
        if ([store.purchaseID isEqualToString:@"14"] && [store.propType.name isEqualToString:@"collage"]) {
            printData = [[PrintData alloc] initWithStoreItem:store andUniqueNum:0];
        }
    }
    
    UIImage *previewImage = [UIImage imageNamed:@"horizontalImage"];
    PrintImage *image1 = [[PrintImage alloc] initWithPreviewImage:previewImage withName:@"image1" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image2 = [[PrintImage alloc] initWithPreviewImage:previewImage withName:@"image2" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image3 = [[PrintImage alloc] initWithPreviewImage:previewImage withName:@"image3" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image4 = [[PrintImage alloc] initWithPreviewImage:previewImage withName:@"image4" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObjects:image1, image2, image3, image4, nil]];
    [printData createAndAddMergedImageWithPrintImage:nil];
    
    
    // Тест не проходит, т.к магнит-коллаж отключен из магазина
//    XCTAssertTrue(printData.mergedImages.count == 1, @"Merge: %lu", (unsigned long)printData.mergedImages.count);
}





#pragma mark - Brelok
- (void)testMergeBrelokSquareImage
{
    UIImage *previewImage = [UIImage imageNamed:@"squareImage"];
    //NSLog(@"previewImage.size: %@", NSStringFromCGSize(previewImage.size));
    
    
    
    UIImage *imageBrelokTop = [UIImage imageNamed:@"brelok_top"];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:imageBrelokTop];
    
    
    
    
    
    
    
    // Размеры фона
    CGSize const brelokSize = CGSizeMake(640, 586);
    
    // Позиция вырезенная в футболке
    CGRect const brelokRectForImage = CGRectMake(198, 173, 244, 305);
    //CGRect const tShirtCrop = CGRectMake(95, 48, 126, 180);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(brelokRectForImage) / brelokSize.width,
                                          CGRectGetMinY(brelokRectForImage) / brelokSize.height,
                                          CGRectGetWidth(brelokRectForImage)/ brelokSize.width,
                                          CGRectGetHeight(brelokRectForImage) / brelokSize.height);
    
    
    CGRect const rectCanvas = CGRectMake(imageBrelokTop.size.width * CGRectGetMinX(persentRect),
                                         imageBrelokTop.size.height * CGRectGetMinY(persentRect),
                                         imageBrelokTop.size.width * CGRectGetWidth(persentRect),
                                         imageBrelokTop.size.height * CGRectGetHeight(persentRect));
    
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectCanvas) / CGRectGetHeight(rectCanvas);
    CGRect cropRect = [[UIImage alloc] sizeImage:previewImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:previewImage WithRect:cropRect];
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectCanvas];
    
    
    // Задний слой
    // Обычная белая футболка
    UIImage *imageBack = [UIImage imageNamed:@"brelok_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageBack];
    
    //
    UIImage *merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    XCTAssertNotNil(merge, @"Merge == nil");
}



- (void) testMergeBrelokHorizonailImage
{
    UIImage *previewImage = [UIImage imageNamed:@"horizontalImage"];
    //NSLog(@"previewImage.size: %@", NSStringFromCGSize(previewImage.size));
    
    
    UIImage *imageBrelokTop = [UIImage imageNamed:@"brelok_top"];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:imageBrelokTop];
    
    
    
    
    
    
    
    // Размеры фона
    CGSize const brelokSize = CGSizeMake(640, 586);
    
    // Позиция вырезенная в футболке
    CGRect const brelokRectForImage = CGRectMake(198, 173, 244, 305);
    //CGRect const tShirtCrop = CGRectMake(95, 48, 126, 180);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(brelokRectForImage) / brelokSize.width,
                                          CGRectGetMinY(brelokRectForImage) / brelokSize.height,
                                          CGRectGetWidth(brelokRectForImage)/ brelokSize.width,
                                          CGRectGetHeight(brelokRectForImage) / brelokSize.height);
    
    
    CGRect const rectCanvas = CGRectMake(imageBrelokTop.size.width * CGRectGetMinX(persentRect),
                                         imageBrelokTop.size.height * CGRectGetMinY(persentRect),
                                         imageBrelokTop.size.width * CGRectGetWidth(persentRect),
                                         imageBrelokTop.size.height * CGRectGetHeight(persentRect));
    
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectCanvas) / CGRectGetHeight(rectCanvas);
    CGRect cropRect = [[UIImage alloc] sizeImage:previewImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:previewImage WithRect:cropRect];
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectCanvas];
    
    
    // Задний слой
    // Обычная белая футболка
    UIImage *imageBack = [UIImage imageNamed:@"brelok_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageBack];
    
    //
    UIImage *merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    XCTAssertNotNil(merge, @"Merge == nil");
}





#pragma mark - Clock
- (void)testMergeClockSquareImage
{
    UIImage *previewImage = [UIImage imageNamed:@"squareImage"];
    //NSLog(@"previewImage.size: %@", NSStringFromCGSize(previewImage.size));
    
    
    
    UIImage *imageClockTop = [UIImage imageNamed:@"clock_top"];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:imageClockTop];
    
    
    
    
    
    
    
    // Размеры фона
    CGSize const clockSize = CGSizeMake(523, 523);
    
    // Позиция вырезенная в футболке
    CGRect const clockRectForImage = CGRectMake(0, 0, clockSize.width, clockSize.height);
    //CGRect const tShirtCrop = CGRectMake(95, 48, 126, 180);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(clockRectForImage) / clockSize.width,
                                          CGRectGetMinY(clockRectForImage) / clockSize.height,
                                          CGRectGetWidth(clockRectForImage)/ clockSize.width,
                                          CGRectGetHeight(clockRectForImage) / clockSize.height);
    
    
    CGRect const rectCanvas = CGRectMake(imageClockTop.size.width * CGRectGetMinX(persentRect),
                                         imageClockTop.size.height * CGRectGetMinY(persentRect),
                                         imageClockTop.size.width * CGRectGetWidth(persentRect),
                                         imageClockTop.size.height * CGRectGetHeight(persentRect));
    
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectCanvas) / CGRectGetHeight(rectCanvas);
    CGRect cropRect = [[UIImage alloc] sizeImage:previewImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:previewImage WithRect:cropRect];
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectCanvas];
    
    
    // Задний слой
    // Обычная белая футболка
    UIImage *imageBack = [UIImage imageNamed:@"clock_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageBack];
    
    //
    UIImage *merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    XCTAssertNotNil(merge, @"Merge == nil");
}



- (void) testMergeClockHorizonailImage
{
    UIImage *previewImage = [UIImage imageNamed:@"horizontalImage"];
    //NSLog(@"previewImage.size: %@", NSStringFromCGSize(previewImage.size));
    
    
    UIImage *imageClockTop = [UIImage imageNamed:@"clock_top"];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:imageClockTop];
    
    
    
    
    
    
    
    // Размеры фона
    CGSize const clockSize = CGSizeMake(523, 523);
    
    // Позиция вырезенная в футболке
    CGRect const clockRectForImage = CGRectMake(0, 0, clockSize.width, clockSize.height);
    //CGRect const tShirtCrop = CGRectMake(95, 48, 126, 180);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(clockRectForImage) / clockSize.width,
                                          CGRectGetMinY(clockRectForImage) / clockSize.height,
                                          CGRectGetWidth(clockRectForImage)/ clockSize.width,
                                          CGRectGetHeight(clockRectForImage) / clockSize.height);
    
    
    CGRect const rectCanvas = CGRectMake(imageClockTop.size.width * CGRectGetMinX(persentRect),
                                         imageClockTop.size.height * CGRectGetMinY(persentRect),
                                         imageClockTop.size.width * CGRectGetWidth(persentRect),
                                         imageClockTop.size.height * CGRectGetHeight(persentRect));
    
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectCanvas) / CGRectGetHeight(rectCanvas);
    CGRect cropRect = [[UIImage alloc] sizeImage:previewImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:previewImage WithRect:cropRect];
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectCanvas];
    
    
    // Задний слой
    // Обычная белая футболка
    UIImage *imageBack = [UIImage imageNamed:@"clock_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageBack];
    
    //
    UIImage *merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    XCTAssertNotNil(merge, @"Merge == nil");
}


#pragma mark - Plate
- (void)testMergePlateSquareImage
{
    UIImage *previewImage = [UIImage imageNamed:@"squareImage"];
    //NSLog(@"previewImage.size: %@", NSStringFromCGSize(previewImage.size));
    
    
    
    UIImage *imagePlateTop = [UIImage imageNamed:@"plate_top"];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:imagePlateTop];
    
    
    
    
    
    
    
    // Размеры фона
    CGSize const plateSize = CGSizeMake(640, 586);
    
    // Позиция вырезенная в футболке
    CGRect const plateRectForImage = CGRectMake(56, 19, 528, 528);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(plateRectForImage) / plateSize.width,
                                          CGRectGetMinY(plateRectForImage) / plateSize.height,
                                          CGRectGetWidth(plateRectForImage)/ plateSize.width,
                                          CGRectGetHeight(plateRectForImage) / plateSize.height);
    
    
    CGRect const rectCanvas = CGRectMake(imagePlateTop.size.width * CGRectGetMinX(persentRect),
                                         imagePlateTop.size.height * CGRectGetMinY(persentRect),
                                         imagePlateTop.size.width * CGRectGetWidth(persentRect),
                                         imagePlateTop.size.height * CGRectGetHeight(persentRect));
    
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectCanvas) / CGRectGetHeight(rectCanvas);
    CGRect cropRect = [[UIImage alloc] sizeImage:previewImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:previewImage WithRect:cropRect];
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectCanvas];
    
    
    // Задний слой
    // Обычная белая футболка
    UIImage *imageBack = [UIImage imageNamed:@"plate_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageBack];
    
    //
    UIImage *merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    XCTAssertNotNil(merge, @"Merge == nil");
}



- (void) testMergePlateHorizonailImage
{
    UIImage *previewImage = [UIImage imageNamed:@"horizontalImage"];
    //NSLog(@"previewImage.size: %@", NSStringFromCGSize(previewImage.size));
    
    
    UIImage *imagePlateTop = [UIImage imageNamed:@"plate_top"];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:imagePlateTop];
    
    
    
    
    
    
    
    // Размеры фона
    CGSize const plateSize = CGSizeMake(640, 586);
    
    // Позиция вырезенная в футболке
    CGRect const plateRectForImage = CGRectMake(56, 19, 528, 528);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(plateRectForImage) / plateSize.width,
                                          CGRectGetMinY(plateRectForImage) / plateSize.height,
                                          CGRectGetWidth(plateRectForImage)/ plateSize.width,
                                          CGRectGetHeight(plateRectForImage) / plateSize.height);
    
    
    CGRect const rectCanvas = CGRectMake(imagePlateTop.size.width * CGRectGetMinX(persentRect),
                                         imagePlateTop.size.height * CGRectGetMinY(persentRect),
                                         imagePlateTop.size.width * CGRectGetWidth(persentRect),
                                         imagePlateTop.size.height * CGRectGetHeight(persentRect));
    
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectCanvas) / CGRectGetHeight(rectCanvas);
    CGRect cropRect = [[UIImage alloc] sizeImage:previewImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:previewImage WithRect:cropRect];
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectCanvas];
    
    
    // Задний слой
    // Обычная белая футболка
    UIImage *imageBack = [UIImage imageNamed:@"plate_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageBack];
    
    //
    UIImage *merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    XCTAssertNotNil(merge, @"Merge == nil");
}




#pragma mark - Mat
- (void)testMergeMatSquareImage
{
    UIImage *previewImage = [UIImage imageNamed:@"squareImage"];
    //NSLog(@"previewImage.size: %@", NSStringFromCGSize(previewImage.size));
    
    
    
    UIImage *imageMatTop = [UIImage imageNamed:@"mat_top"];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:imageMatTop];
    
    
    
    
    
    
    
    // Размеры фона
    CGSize const matSize = CGSizeMake(507, 572);
    
    // Позиция вырезенная в футболке
    CGRect const matRectForImage = CGRectMake(0, 0, matSize.width, 424);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(matRectForImage) / matSize.width,
                                          CGRectGetMinY(matRectForImage) / matSize.height,
                                          CGRectGetWidth(matRectForImage)/ matSize.width,
                                          CGRectGetHeight(matRectForImage) / matSize.height);
    
    
    CGRect const rectCanvas = CGRectMake(imageMatTop.size.width * CGRectGetMinX(persentRect),
                                         imageMatTop.size.height * CGRectGetMinY(persentRect),
                                         imageMatTop.size.width * CGRectGetWidth(persentRect),
                                         imageMatTop.size.height * CGRectGetHeight(persentRect));
    
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectCanvas) / CGRectGetHeight(rectCanvas);
    CGRect cropRect = [[UIImage alloc] sizeImage:previewImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:previewImage WithRect:cropRect];
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectCanvas];
    
    
    // Задний слой
    // Обычная белая футболка
    UIImage *imageBack = [UIImage imageNamed:@"mat_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageBack];
    
    //
    UIImage *merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    XCTAssertNotNil(merge, @"Merge == nil");
}



- (void) testMergeMouseHorizonailImage
{
    UIImage *previewImage = [UIImage imageNamed:@"horizontalImage"];
    //NSLog(@"previewImage.size: %@", NSStringFromCGSize(previewImage.size));
    
    
    UIImage *imageMatTop = [UIImage imageNamed:@"mat_top"];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:imageMatTop];
    
    
    
    
    
    
    
    // Размеры фона
    CGSize const matSize = CGSizeMake(507, 572);
    
    // Позиция вырезенная в футболке
    CGRect const matRectForImage = CGRectMake(0, 0, matSize.width, 424);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(matRectForImage) / matSize.width,
                                          CGRectGetMinY(matRectForImage) / matSize.height,
                                          CGRectGetWidth(matRectForImage)/ matSize.width,
                                          CGRectGetHeight(matRectForImage) / matSize.height);
    
    
    CGRect const rectCanvas = CGRectMake(imageMatTop.size.width * CGRectGetMinX(persentRect),
                                         imageMatTop.size.height * CGRectGetMinY(persentRect),
                                         imageMatTop.size.width * CGRectGetWidth(persentRect),
                                         imageMatTop.size.height * CGRectGetHeight(persentRect));
    
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectCanvas) / CGRectGetHeight(rectCanvas);
    CGRect cropRect = [[UIImage alloc] sizeImage:previewImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:previewImage WithRect:cropRect];
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectCanvas];
    
    
    // Задний слой
    // Обычная белая футболка
    UIImage *imageBack = [UIImage imageNamed:@"mat_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageBack];
    
    //
    UIImage *merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    XCTAssertNotNil(merge, @"Merge == nil");
}




#pragma mark - Mug Class
- (void) testMergeMugSquareImage
{
    //
    UIImage *previewImage = [UIImage imageNamed:@"squareImage"];
    
    // Футболка с вырезанной областью
    UIImage *imageMugGlass = [UIImage imageNamed:@"mug_glass"];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:imageMugGlass];
    
    
    
    // Здесь формируем картинку, ответ в Delegate
    CGFloat ratio = 1.76;//588 / 248.f;
    EllipseModel *ellipseModel = [[EllipseModel alloc] initImage:previewImage
                                                 withOrientation:CupOrientationToRight
                                                  andAspectRatio:ratio
                                               andEllipseDistort:/*photoObject == PhotoObjectCupLatte ? CupTypeFlexibleLatte : */CupTypeFlexibleStandart];
    //[ellipseModel setDelegate:self];
    
    
    
    // Размеры фона
    CGSize const tShirtSize = CGSizeMake(640, 586);
    
    // Позиция вырезенная в футболке
    CGRect const tShirtRectForImage = CGRectMake(190, 97, 252, 361);
    //CGRect const tShirtCrop = CGRectMake(95, 48, 126, 180);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(tShirtRectForImage) / tShirtSize.width,
                                          CGRectGetMinY(tShirtRectForImage) / tShirtSize.height,
                                          CGRectGetWidth(tShirtRectForImage)/ tShirtSize.width,
                                          CGRectGetHeight(tShirtRectForImage) / tShirtSize.height);
    
    
    CGRect const rectTshirt = CGRectMake(imageMugGlass.size.width * CGRectGetMinX(persentRect),
                                         imageMugGlass.size.height * CGRectGetMinY(persentRect),
                                         imageMugGlass.size.width * CGRectGetWidth(persentRect),
                                         imageMugGlass.size.height * CGRectGetHeight(persentRect));
    
    //NSLog(@"rectTShirt: %@", NSStringFromCGRect(rectTshirt));
    
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectTshirt) / CGRectGetHeight(rectTshirt);
    CGRect cropRect = [[UIImage alloc] sizeImage:previewImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:previewImage WithRect:cropRect];
    //NSLog(@"cropImage: %@", NSStringFromCGSize(cropimage.size));
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectTshirt];
    
    
    
    // Задний слой
    // Обычная белая футболка
    //UIImage *imageBack = [UIImage imageNamed:@"T-shirt_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:nil];
    
    /*NSLog(@"UpperImageView: %@", NSStringFromCGRect(shadowImageView.frame));
     NSLog(@"ImageView: %@", NSStringFromCGRect(imageView.frame));
     NSLog(@"BottomImageView: %@", NSStringFromCGRect(objectImageView.frame));*/
    
    
    //
    __block UIImage *merge;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    });

}
@end
