//
//  TShirtStrategy.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/11/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "TShirtStrategy.h"

#import "PropSize.h"

@implementation TShirtStrategy
-(UIImage *)showcaseImage
{
    return [UIImage imageNamed:@"T-shirt_back"];
}




-(NSDictionary *)props
{
    PropType *propType = [self.storeItem.types firstObject];
    
    NSDictionary * dictionary = [NSDictionary dictionaryWithObjectsAndKeys: propType.selectPropSize.sizeName,   @"size",
                                                                            propType.name,                      @"type", nil];
    return dictionary;
}



-(NSArray *)createAndAddMergedImage:(UIImage *)previewImage
{
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
    UIImage *imageBack = [UIImage imageNamed:@"T-shirt_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageBack];
    
    /*NSLog(@"UpperImageView: %@", NSStringFromCGRect(shadowImageView.frame));
    NSLog(@"ImageView: %@", NSStringFromCGRect(imageView.frame));
    NSLog(@"BottomImageView: %@", NSStringFromCGRect(objectImageView.frame));*/
    
    
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
