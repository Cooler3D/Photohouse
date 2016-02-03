//
//  UIImageView+CompareCrop.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/27/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "UIImageView+CompareCrop.h"

@implementation UIImageView (CompareCrop)
- (BOOL) compareSquareHitTestCropView:(UIImageView*)cropView withMaxSquare:(NSInteger)maxSquare {
    UIImageView *imageView = self;
    
    
    CGSize cropViewSize = cropView.frame.size;
    CGSize imageViewSize = imageView.frame.size;
    
    CGSize imageSize = imageView.image.size;
    
    
    
    CGFloat resultWidth;
    CGFloat resultHeight;
    
    NSLog(@"CropView: %@", NSStringFromCGRect(cropView.frame));
    NSLog(@"ImageView: %@", NSStringFromCGRect(imageView.frame));
    NSLog(@"Image: %@", NSStringFromCGSize(imageSize));
    
    //
    if (cropViewSize.width > imageViewSize.width && cropViewSize.height > imageViewSize.height) {
        // Картинка меньше зоны Crop
        // Отправляем размеры картинки
        resultWidth = imageSize.width;
        resultHeight = imageSize.height;
        
        
    } else if(cropViewSize.width > imageViewSize.width && cropViewSize.height < imageViewSize.height) {
        // Картинка по Ширине меньше Crop
        // По Высоте больше Crop
        resultWidth = imageSize.width;
        resultHeight = [self calculateHeight:imageView withCropView:cropView];
        
        
    } else if(cropViewSize.width < imageViewSize.width && cropViewSize.height > imageViewSize.height) {
        // Картинка по Ширине больше Crop
        // По Высоте меньше Crop
        resultWidth = [self calculateWidth:imageView withCropView:cropView];
        resultHeight = imageSize.height;
        
    } else {
        // Картинка больше по Ширине и Высоте
        resultWidth = (CGRectGetWidth(cropView.frame) == CGRectGetWidth(imageView.frame)) ? imageSize.width : [self calculateWidth:imageView withCropView:cropView];
        resultHeight = (CGRectGetHeight(cropView.frame) == CGRectGetHeight(imageView.frame)) ? imageSize.height : [self calculateHeight:imageView withCropView:cropView];
    }


    CGFloat square = resultHeight * resultWidth / maxSquare;
    CGSize sizeTest = CGSizeMake(resultWidth, resultHeight);
    NSLog(@"compareSquare Size: %@", NSStringFromCGSize(sizeTest));
    NSLog(@"maxSquare: %f; square: %f", maxSquare/1000000.f, (resultHeight * resultWidth)/1000000.f);
    if (square > 1) {
        return NO;
    } else {
        return YES;
    }
}




- (CGFloat) calculateWidth:(UIImageView*)imageView withCropView:(UIImageView*)cropView {
    CGFloat widthPersent = CGRectGetWidth(cropView.frame) * 100 / CGRectGetWidth(imageView.frame);
    
    CGFloat widthImage = widthPersent * imageView.image.size.width / 100;
    
    return widthImage;
}


- (CGFloat) calculateHeight:(UIImageView*)imageView withCropView:(UIImageView*)cropView {
    CGFloat heightPersent = CGRectGetWidth(cropView.frame) * 100 / CGRectGetHeight(imageView.frame);//CGRectGetHeight(cropView.frame) * 100 / CGRectGetWidth(imageView.frame);
    
    CGFloat heightImage = heightPersent * imageView.image.size.height / 100;
    
    return heightImage;
}



//#pragma mark - CalculateMaxSize

//- (CGRect) calculateMaxSizeInViewSize:(CGSize)size
//{
//    UIImageView *imageView = self;
//    return CGRectZero;
//}
@end
