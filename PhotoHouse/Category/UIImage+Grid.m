//
//  UIImage+Grid.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/15/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "UIImage+Grid.h"

@implementation UIImage (Grid)
+ (UIImage *) drawGridWithSize:(CGRect)rect
{
    // Drawing code
    CGContextRef contex = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(contex, 4.f);
    CGContextSetLineCap(contex, kCGLineCapRound);
    
    // Square
    CGContextMoveToPoint(contex, CGRectGetMinX(rect), CGRectGetMinY(rect)+2.f);             // First Line
    CGContextAddLineToPoint(contex, CGRectGetMaxX(rect), CGRectGetMinY(rect)+2.f);
    
    CGContextMoveToPoint(contex, CGRectGetMaxX(rect) - 2.f, CGRectGetMinY(rect));           // Second Line
    CGContextAddLineToPoint(contex, CGRectGetMaxX(rect) - 2.f, CGRectGetMaxY(rect));
    
    CGContextMoveToPoint(contex, CGRectGetMaxX(rect), CGRectGetMaxY(rect)-2.f);             // Third Line
    CGContextAddLineToPoint(contex, CGRectGetMinX(rect), CGRectGetMaxY(rect)-2.f);
    
    CGContextMoveToPoint(contex, CGRectGetMinX(rect) + 2.f, CGRectGetMaxY(rect));           // Four Line
    CGContextAddLineToPoint(contex, CGRectGetMinX(rect) + 2.f, CGRectGetMinY(rect));
    
    
    CGContextSetStrokeColorWithColor(contex, [UIColor whiteColor].CGColor);
    
    CGContextStrokePath(contex);
    
    
    
    
    // Horizontal, Vertical
    CGContextSetLineWidth(contex, 2.5f);
    CGContextSetLineCap(contex, kCGLineCapRound);
    
    CGContextMoveToPoint(contex, CGRectGetMinX(rect), CGRectGetMidY(rect));           // Horizontal Line
    CGContextAddLineToPoint(contex, CGRectGetMaxX(rect), CGRectGetMidY(rect));
    
    CGContextMoveToPoint(contex, CGRectGetMidX(rect), CGRectGetMinY(rect));           // Vertial Line
    CGContextAddLineToPoint(contex, CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextSetStrokeColorWithColor(contex, [UIColor whiteColor].CGColor);
    
    CGContextStrokePath(contex);
    
    if (CGRectGetWidth(rect) > CGRectGetHeight(rect)) {
        [self createMoreVerticalLines:contex andFrameRect:rect];
    } else if (CGRectGetWidth(rect) < CGRectGetHeight(rect)) {
        [self createMoreHorizontalLines:contex andFrameRect:rect];
    }
    return nil;
}



+ (void) createMoreHorizontalLines:(CGContextRef)contex andFrameRect:(CGRect)rect
{
    // Horizontal, Vertical
    CGContextSetLineWidth(contex, 2.5f);
    CGContextSetLineCap(contex, kCGLineCapRound);
    
    CGContextMoveToPoint(contex, CGRectGetMinX(rect), CGRectGetMidY(rect));           // Horizontal Line
    CGContextAddLineToPoint(contex, CGRectGetMaxX(rect), CGRectGetMidY(rect));
    
    CGContextMoveToPoint(contex, CGRectGetMidX(rect), CGRectGetMinY(rect));           // Vertial Line
    CGContextAddLineToPoint(contex, CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    
    
    
    CGContextMoveToPoint(contex, CGRectGetMinX(rect), CGRectGetMidY(rect) / 2);           // Horizontal Line
    CGContextAddLineToPoint(contex, CGRectGetMaxX(rect), CGRectGetMidY(rect) / 2);
    
    
    CGContextMoveToPoint(contex, CGRectGetMinX(rect), CGRectGetMidY(rect) / 2 + CGRectGetMidY(rect));// Horizontal Line
    CGContextAddLineToPoint(contex, CGRectGetMaxX(rect), CGRectGetMidY(rect)/ 2 + CGRectGetMidY(rect));
    
    
    
    CGContextSetStrokeColorWithColor(contex, [UIColor whiteColor].CGColor);
    
    CGContextStrokePath(contex);
}


+ (void) createMoreVerticalLines:(CGContextRef)contex andFrameRect:(CGRect)rect
{
    // Horizontal, Vertical
    CGContextSetLineWidth(contex, 2.5f);
    CGContextSetLineCap(contex, kCGLineCapRound);
    
    CGContextMoveToPoint(contex, CGRectGetMinX(rect), CGRectGetMidY(rect));           // Horizontal Line
    CGContextAddLineToPoint(contex, CGRectGetMaxX(rect), CGRectGetMidY(rect));
    
    CGContextMoveToPoint(contex, CGRectGetMidX(rect), CGRectGetMinY(rect));           // Vertial Line
    CGContextAddLineToPoint(contex, CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    
    CGContextMoveToPoint(contex, CGRectGetMidX(rect) / 2, CGRectGetMinY(rect));           // Vertial Line
    CGContextAddLineToPoint(contex, CGRectGetMidX(rect) / 2, CGRectGetMaxY(rect));
    
    
    CGContextMoveToPoint(contex, CGRectGetMidX(rect) / 2 + CGRectGetMidX(rect), CGRectGetMinY(rect));// Vertial Line
    CGContextAddLineToPoint(contex, CGRectGetMidX(rect) / 2 + CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    
    
    CGContextSetStrokeColorWithColor(contex, [UIColor whiteColor].CGColor);
    
    CGContextStrokePath(contex);
}

@end
