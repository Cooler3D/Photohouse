//
//  PlateStrategy.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/11/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PlateStrategy.h"

@implementation PlateStrategy
-(UIImage *)showcaseImage
{
    return [UIImage imageNamed:@"plate_back"];
}



-(NSArray *)createAndAddMergedImage:(UIImage *)previewImage
{
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
