//
//  EditMaskView.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/29/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "EditMaskView.h"

@interface EditMaskView ()
@property (assign, nonatomic) CGRect cutRect;
@end

@implementation EditMaskView

- (id)initWithFrame:(CGRect)frame withCutFrame:(CGRect)cutRect
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.cutRect = cutRect;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAlpha:0.5f];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGRect maskRect = self.cutRect;
    
    // Rectangle
    CGContextRef contex = UIGraphicsGetCurrentContext();
    
    UIColor *fillColor = [UIColor colorWithRed:2/255.f green:11/255.f blue:18/255.f alpha:1.f];
    CGContextSetFillColorWithColor(contex, fillColor.CGColor);
    
    // Формируем 4-ре прямоугольника
    CGRect square1 = CGRectMake(CGRectGetMinX(rect),        CGRectGetMinY(rect),        CGRectGetWidth(rect),                           CGRectGetMinY(maskRect));
    CGRect square2 = CGRectMake(CGRectGetMinX(rect),        CGRectGetMinY(maskRect),    CGRectGetMinX(maskRect),                        CGRectGetHeight(maskRect));
    CGRect square3 = CGRectMake(CGRectGetMaxX(maskRect),    CGRectGetMinY(maskRect),    CGRectGetMaxX(rect) - CGRectGetMaxX(maskRect),  CGRectGetHeight(maskRect));
    CGRect square4 = CGRectMake(CGRectGetMinX(rect),        CGRectGetMaxY(maskRect),    CGRectGetWidth(rect),                           CGRectGetMaxY(rect) - CGRectGetMaxY(maskRect));
    
    CGContextAddRect(contex, square1);
    CGContextAddRect(contex, square2);
    CGContextAddRect(contex, square3);
    CGContextAddRect(contex, square4);
    
    CGContextFillPath(contex);
}


@end
