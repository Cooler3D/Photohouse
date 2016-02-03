//
//  HolstStrategy.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/11/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "HolstStrategy.h"

@implementation HolstStrategy
-(UIImage *)showcaseImage
{
    return [UIImage imageNamed:@"canvas_back"];
}



-(NSArray *)createAndAddMergedImage:(UIImage *)previewImage
{
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
    
    //NSLog(@"rectTShirt: %@", NSStringFromCGRect(rectTshirt));
    
    //CGRect imageRect = CGRectMake(68, 48.5f, 180, 180);// Final
    //[imageView setFrame:imageRect];
    
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectCanvas) / CGRectGetHeight(rectCanvas);
    CGRect cropRect = [[UIImage alloc] sizeImage:previewImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:previewImage WithRect:cropRect];
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectCanvas];
    
    
    // Проверяем соответствует ли пропорции
    //XCTAssertEqual(CGRectGetHeight(cropRect) * CGRectGetWidth(rectTshirt) / CGRectGetHeight(rectTshirt), CGRectGetWidth(cropRect), @"Dont: %f", CGRectGetWidth(cropRect));
    
    
    // Задний слой
    // Обычная белая футболка
    UIImage *imageBack = [UIImage imageNamed:@"canvas_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageBack];
    
    
    //
    //
    __block UIImage *merge;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    });
    
    PrintImage *merged = [[PrintImage alloc] initMergeImage:merge withName:@"merge_canvas" andUploadUrl:nil];
    return [NSArray arrayWithObject:merged];
}

-(void)createMergedImageWithPreview:(UIImage *)previewImage andCompleteBlock:(void (^)(NSArray *))completeBlock andProgressBlock:(void(^)(CGFloat progress))progressBlock
{
    if (completeBlock) {
        completeBlock([self createAndAddMergedImage:previewImage]);
    }
}
@end
