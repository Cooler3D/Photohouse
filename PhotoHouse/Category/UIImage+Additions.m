//
//  UIImage+Additions.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 10/01/16.
//  Copyright © 2016 Мартынов Дмитрий. All rights reserved.
//

#import "UIImage+Additions.h"

static inline double radians (double degrees) {return degrees * M_PI/180;}

UIImage *rotatedImage(UIImage *image, CGFloat rotation)
{
    // Calculate Destination Size
    CGAffineTransform t = CGAffineTransformMakeRotation(rotation);
    CGRect sizeRect = (CGRect) {.size = image.size};
    CGRect destRect = CGRectApplyAffineTransform(sizeRect, t);
    CGSize destinationSize = destRect.size;
    
    // Draw image
    UIGraphicsBeginImageContext(destinationSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, destinationSize.width / 2.0f, destinationSize.height / 2.0f);
    CGContextRotateCTM(context, rotation);
    [image drawInRect:CGRectMake(-image.size.width / 2.0f, -image.size.height / 2.0f, image.size.width, image.size.height)];
    
    // Save image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@implementation UIImage (Additions)
- (UIImage *)imageOrientationNormalize {
    CGFloat theta = 0;
    
    NSInteger orientation = self.imageOrientation;
    if (orientation == UIImageOrientationRight) {
        theta = radians(-90);
    } else if (orientation == UIImageOrientationLeft) {
        theta = radians(-90);
    } else if (orientation == UIImageOrientationDown) {
        theta = radians(180);
    }
    
    return rotatedImage(self, theta);
}
@end
