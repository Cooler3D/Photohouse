//
//  UIImage+Merge.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 23/11/15.
//  Copyright © 2015 Мартынов Дмитрий. All rights reserved.
//

#import "UIImage+Merge.h"

@implementation UIImage (Merge)
-(UIImage *)mergeImage:(UIImage *)image withAtPoint:(CGPoint)point {
    UIImage *original = self;
    
    CGSize newImageSize = original.size;
    
//    if (UIGraphicsBeginImageContextWithOptions != NULL) {
//        UIGraphicsBeginImageContextWithOptions(newImageSize, NO, [[UIScreen mainScreen] scale]);
//    } else {
        UIGraphicsBeginImageContext(newImageSize);
//    }
    
    [original drawAtPoint:CGPointMake(0, 0)];
    [image drawAtPoint:point];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}
@end
