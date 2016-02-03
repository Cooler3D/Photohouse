//
//  UIImage+MinimalSize.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/4/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "UIImage+MinimalSize.h"

@implementation UIImage (MinimalSize)
- (BOOL) isMinimalImageSize:(CGFloat)square
{
    CGFloat maxSquare = square * 1000000.f;
    
    CGFloat imageWidth = self.size.width;
    CGFloat imageHeight = self.size.height;
    
    CGFloat imageSquare = imageHeight * imageWidth;
    
    
    return imageSquare > maxSquare ? NO : YES;
}
@end
