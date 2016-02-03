//
//  ClockStrategy.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/11/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "ClockStrategy.h"

@implementation ClockStrategy
-(UIImage *)showcaseImage
{
    return [UIImage imageNamed:@"clock_back"];
}


-(NSArray *)createAndAddMergedImage:(UIImage *)previewImage
{
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
    __block UIImage *merge;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    });
    
    PrintImage *merged = [[PrintImage alloc] initMergeImage:merge withName:@"merge_tshirt" andUploadUrl:nil];
    return [NSArray arrayWithObject:merged];

}

-(void)createMergedImageWithPreview:(UIImage *)previewImage andCompleteBlock:(void (^)(NSArray *))completeBlock andProgressBlock:(void(^)(CGFloat progress))progressBlock
{
    if (completeBlock) {
        completeBlock([self createAndAddMergedImage:previewImage]);
    }
}
@end
