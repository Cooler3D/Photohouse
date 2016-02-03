//
//  MouseMagStrategy.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/11/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "MouseMagStrategy.h"

@implementation MouseMagStrategy
-(UIImage *)showcaseImage
{
    return [UIImage imageNamed:@"mat_back"];
}



-(NSArray *)createAndAddMergedImage:(UIImage *)previewImage
{
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
    __block UIImage *merge;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    });
    
    PrintImage *merged = [[PrintImage alloc] initMergeImage:merge withName:@"merge_mat" andUploadUrl:nil];
    return [NSArray arrayWithObject:merged];
}

-(void)createMergedImageWithPreview:(UIImage *)previewImage andCompleteBlock:(void (^)(NSArray *))completeBlock andProgressBlock:(void(^)(CGFloat progress))progressBlock
{
    if (completeBlock) {
        completeBlock([self createAndAddMergedImage:previewImage]);
    }
}
@end
