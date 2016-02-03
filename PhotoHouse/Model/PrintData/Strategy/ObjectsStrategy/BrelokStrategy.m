//
//  BrelokStrategy.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/11/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "BrelokStrategy.h"

@implementation BrelokStrategy
-(UIImage *)showcaseImage
{
    return [UIImage imageNamed:@"brelok_back"];
}



-(NSArray *)createAndAddMergedImage:(UIImage *)previewImage
{
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
