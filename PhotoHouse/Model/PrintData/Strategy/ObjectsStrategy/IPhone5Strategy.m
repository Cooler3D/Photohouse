//
//  IPhone5Strategy.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/21/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "IPhone5Strategy.h"

@implementation IPhone5Strategy
-(UIImage *)showcaseImage
{
    return [UIImage imageNamed:@"Case5_back"];
}



-(NSArray *)createAndAddMergedImage:(UIImage *)previewImage
{
    // Чехол
    UIImage *imageIphone5Top = [UIImage imageNamed:@"Case5_top"];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:imageIphone5Top];
    
    
    
    
    
    
    
    // Размеры фона
    CGSize const tIphone5Size = CGSizeMake(258, 533);
    
    // Позиция вырезенная
    CGRect const tIphone5RectForImage = CGRectMake(0, 0, tIphone5Size.width, tIphone5Size.height);
    //CGRect const tShirtCrop = CGRectMake(95, 48, 126, 180);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(tIphone5RectForImage) / tIphone5Size.width,
                                          CGRectGetMinY(tIphone5RectForImage) / tIphone5Size.height,
                                          CGRectGetWidth(tIphone5RectForImage)/ tIphone5Size.width,
                                          CGRectGetHeight(tIphone5RectForImage) / tIphone5Size.height);
    
    
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
    //NSLog(@"image: %@", merge);
    PrintImage *merged = [[PrintImage alloc] initMergeImage:merge withName:@"merge_iphone5" andUploadUrl:nil];
    return [NSArray arrayWithObject:merged];
}

-(void)createMergedImageWithPreview:(UIImage *)previewImage andCompleteBlock:(void (^)(NSArray *))completeBlock andProgressBlock:(void(^)(CGFloat progress))progressBlock
{
    if (completeBlock) {
        completeBlock([self createAndAddMergedImage:previewImage]);
    }
}
@end
