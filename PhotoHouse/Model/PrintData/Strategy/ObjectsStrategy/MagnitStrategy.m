//
//  MagnitStrategy.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/11/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "MagnitStrategy.h"

#import "PropSize.h"
#import "PropUturn.h"
#import "PropCover.h"
#import "PropStyle.h"
#import "PropColor.h"

#import "UIImage+Crop.h"

@implementation MagnitStrategy

-(UIImage *)showcaseImage
{
    PropType *propType = [self.storeItem.types firstObject];
    UIImage *image;
    if ([propType.name isEqualToString:@"heart"])
    {
        image = [UIImage imageNamed:@"magnet_heart_back"];
    }
    else
    {
        image = [UIImage imageNamed:@"magnet_14_21_top"];
    }
    
    return image;
}




-(UIImage *)iconImage
{
    PropType *propType = [self.storeItem.types firstObject];
    UIImage *image;
    if ([propType.name isEqualToString:@"heart"])
    {
        image = [UIImage imageNamed:@"magnet_heart_128"];
    }
    else
    {
        image = [UIImage imageNamed:@"magnet_128"];
    }
    
    return image;
}

-(NSDictionary *)props
{
    PropType *propType = [self.storeItem.types firstObject];
    
    NSDictionary * dictionary = [NSDictionary dictionaryWithObjectsAndKeys:  propType.selectPropSize.sizeName,            @"size",
                                                                             propType.name,                           @"type",    nil];
    return dictionary;
}
-(NSArray *)createAndAddMergedImage:(UIImage *)previewImage
{
    PropType *propType = [self.storeItem.types firstObject];
    NSArray *result;
    if ([propType.name isEqualToString:@"heart"])
    {
        result = [self createMagnitHeart:previewImage];
    }
    else
    {
        NSMutableArray *images = [NSMutableArray array];
        for (PrintImage *image in self.imagesPreview) {
            [images addObject:image.previewImage];
        }
        NSString *path = [NSString stringWithFormat:@"grid_%@_%@", self.storeItem.purchaseID, propType.name];
        UIImage *grid = [UIImage imageNamed:path];
        result = [self createMagnitCollage:images aspectRatio:grid.size.width / grid.size.height];
    }

    return result;
}

-(void)createMergedImageWithPreview:(UIImage *)previewImage andCompleteBlock:(void (^)(NSArray *))completeBlock andProgressBlock:(void(^)(CGFloat progress))progressBlock
{
    if (completeBlock) {
        completeBlock([self createAndAddMergedImage:previewImage]);
    }
}


#pragma mark - Private
- (NSArray *) createMagnitHeart:(UIImage *)previewImage
{
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
    UIImage *imageBack = [UIImage imageNamed:@"magnet_heart_back"];
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



- (NSArray *) createMagnitCollage:(NSArray *)images aspectRatio:(CGFloat)aspectRatio
{
    CGRect rect1 = [[UIImage alloc] sizeImage:(UIImage *)[images firstObject] withDelitelHeight:aspectRatio];
    UIImage *firstImage = [[UIImage alloc] cropImageFrom:[images firstObject] WithRect:rect1];
    
    
    CGRect rect2 = [[UIImage alloc] sizeImage:(UIImage *)[images objectAtIndex:1] withDelitelHeight:aspectRatio];
    UIImage *secondImage = [[UIImage alloc] cropImageFrom:[images objectAtIndex:1] WithRect:rect2];
    
    UIImage *final1 = [firstImage mergeImage:secondImage toOrientation:MergeOrientaionToWidth];
    
    
    CGRect rect3 = [[UIImage alloc] sizeImage:(UIImage *)[images objectAtIndex:2] withDelitelHeight:aspectRatio];
    UIImage *third = [[UIImage alloc] cropImageFrom:[images objectAtIndex:2] WithRect:rect3];
    
    
    CGRect rect4 = [[UIImage alloc] sizeImage:(UIImage *)[images objectAtIndex:3] withDelitelHeight:aspectRatio];
    UIImage *four = [[UIImage alloc] cropImageFrom:[images objectAtIndex:3] WithRect:rect4];
    
    UIImage *final2 = [third mergeImage:four toOrientation:MergeOrientaionToWidth];
    UIImage *final = [final1 mergeImage:final2 toOrientation:MergeOrientaionToHeight];
    
    PrintImage *merge = [[PrintImage alloc] initMergeImage:final withName:@"merge_magnit_collage" andUploadUrl:nil];
    return [NSArray arrayWithObject:merge];
}


- (UIImage *) calculateAndCropImage:(UIImage *)previewImage
{
    return previewImage;
}

@end
