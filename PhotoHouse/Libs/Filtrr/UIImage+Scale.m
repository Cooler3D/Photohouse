//
//  UIImage+Scale.m
//  FiltrrApp
//
//  Created by Omid Hashemi on 2/10/12.
//  Copyright (c) 2012 42dp. All rights reserved.
//

#import "UIImage+Scale.h"

@implementation UIImage (Scale)

-(UIImage*)scaleToSize:(CGSize)size {
    // Create a bitmap graphics context
    // This will also set it as the current context
    UIGraphicsBeginImageContext(size);
    // Draw the scaled image in the current context
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // Create a new image from current context
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // Pop the current context from the stack
    UIGraphicsEndImageContext();
    // Return our new scaled image
    return scaledImage;
}

-(UIImage *) crop:(CGRect) cropRect {
//    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
//    // or use the UIImage wherever you like
//    UIImage *retImage = [UIImage imageWithCGImage:imageRef]; 
//    CGImageRelease(imageRef);
    
    if (self.scale > 1.0f) {
        cropRect = CGRectMake(cropRect.origin.x * self.scale,
                          cropRect.origin.y * self.scale,
                          cropRect.size.width * self.scale,
                          cropRect.size.height * self.scale);
    }
    
    // Оригинальные значения в процентах для ВЕРТИКАЛЬНОЙ картинки
    CGFloat persentX = CGRectGetMinX(cropRect) * 100.f / self.size.width;
    CGFloat persentY = CGRectGetMinY(cropRect) * 100.f / self.size.height;
    CGFloat persentW = CGRectGetWidth(cropRect) * 100.f / self.size.width;
    CGFloat persentH = CGRectGetHeight(cropRect) * 100.f / self.size.height;
    CGFloat posX;
    CGFloat posY;
    CGFloat posW;
    CGFloat posH;
    
    switch (self.imageOrientation) {
        case UIImageOrientationUp:
            // Здесь ничего не считаем
            //NSLog(@"UIImageOrientationUp");
            break;
            
        case UIImageOrientationDown:
            //NSLog(@"UIImageOrientationDown%@", NSStringFromCGSize(self.size));
            //NSLog(@"Crop.OLD: %@", NSStringFromCGRect(cropRect));
            posX = (100 - persentX - persentW) * self.size.width / 100;
            posY = (100 - persentY - persentH) * self.size.height / 100;
            posW = persentH * self.size.height / 100;
            posH = persentW * self.size.width / 100;
            cropRect = CGRectMake(posX, posY, posH, posW);
            NSLog(@"Crop.UPDATE: %@", NSStringFromCGRect(cropRect));
            break;
            
        case UIImageOrientationLeft:
            //NSLog(@"UIImageOrientationLeft %@", NSStringFromCGSize(self.size));
            //NSLog(@"Crop.OLD: %@", NSStringFromCGRect(cropRect));
            posX = (persentX) * self.size.width / 100.f;
            posY = (100.f - persentY - persentH) * self.size.height / 100.f;
            posW = persentH * self.size.height / 100.f;
            posH = persentW * self.size.width / 100.f;
            cropRect = CGRectMake(posY, posX, posW, posH);
            NSLog(@"Crop.UPDATE: %@", NSStringFromCGRect(cropRect));
            break;
            
        case UIImageOrientationRight:
            //NSLog(@"UIImageOrientationRight: %@", NSStringFromCGSize(self.size));
            //NSLog(@"Crop.OLD: %@", NSStringFromCGRect(cropRect));
            posX = (100.f - persentX - persentW) * self.size.width / 100.f;
            posY = persentY * self.size.height / 100.f;
            posW = persentH * self.size.height / 100.f;
            posH = persentW * self.size.width / 100.f;
            cropRect = CGRectMake(posY, posX, posW, posH);
            //NSLog(@"Crop.UPDATE: %@", NSStringFromCGRect(cropRect));
            break;
            
        default:
            break;
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    UIImage *retImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    
    return retImage;
}

@end
