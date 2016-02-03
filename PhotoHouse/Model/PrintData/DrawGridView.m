//
//  DrawGridView.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/7/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "DrawGridView.h"

typedef enum {
    DrawTypeGrid,
    DrawTypeRectangle,
    DrawTypeSelect
} DrawType;


@interface DrawGridView ()
@property (assign, nonatomic) DrawType drawType;

@property (strong, nonatomic) UIColor *rectangleColor;
@property (assign, nonatomic) CGFloat lineWidth;
@end


@implementation DrawGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

-(id)initGridWithFrame:(CGSize)size
{
    self = [self initWithFrame:CGRectMake(0.f, 0.f, size.width, size.height)];
    self.drawType = DrawTypeGrid;
    return self;
}

-(id)initRectangleWithSize:(CGSize)size andColorLine:(UIColor *)colorLine andStrokeLineWidth:(CGFloat)lineWidth
{
    self = [self initWithFrame:CGRectMake(0.f, 0.f, size.width, size.height)];
    self.drawType = DrawTypeRectangle;
    self.lineWidth = lineWidth;
    self.rectangleColor = colorLine;
    return self;
}


-(id)initDrawSelectImageWtihSize:(CGSize)size andColorLine:(UIColor *)colorLine andStrokeLineWidth:(CGFloat)lineWidth
{
    self = [self initWithFrame:CGRectMake(0.f, 0.f, size.width, size.height)];
    self.drawType = DrawTypeSelect;
    self.lineWidth = lineWidth;
    self.rectangleColor = colorLine;
    return self;

}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    switch (self.drawType) {
        case DrawTypeGrid:
            [self drawGrid:rect];
            break;
            
        case DrawTypeRectangle:
            [self drawRectangle:rect];
            break;
            
        case DrawTypeSelect:
            [self drawSelectImage:rect];
            break;
    }
}


#pragma mark - Draw Rectangle
- (void) drawRectangle:(CGRect)rect
{
    CGFloat lineWidth = self.lineWidth;
    CGFloat offsetLine = lineWidth / 2; // Отстус в зависимости от ширины линии
    
    // Drawing code
    CGContextRef contex = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(contex, lineWidth);
    CGContextSetLineCap(contex, kCGLineCapRound);
    
    // Square
    CGContextMoveToPoint(contex, CGRectGetMinX(rect), CGRectGetMinY(rect)+offsetLine);             // First Line
    CGContextAddLineToPoint(contex, CGRectGetMaxX(rect), CGRectGetMinY(rect) + offsetLine);
    
    CGContextMoveToPoint(contex, CGRectGetMaxX(rect) - offsetLine, CGRectGetMinY(rect));           // Second Line
    CGContextAddLineToPoint(contex, CGRectGetMaxX(rect) - offsetLine, CGRectGetMaxY(rect));
    
    CGContextMoveToPoint(contex, CGRectGetMaxX(rect), CGRectGetMaxY(rect)-offsetLine);             // Third Line
    CGContextAddLineToPoint(contex, CGRectGetMinX(rect), CGRectGetMaxY(rect)-offsetLine);
    
    CGContextMoveToPoint(contex, CGRectGetMinX(rect) + offsetLine, CGRectGetMaxY(rect));           // Four Line
    CGContextAddLineToPoint(contex, CGRectGetMinX(rect) + offsetLine, CGRectGetMinY(rect));
    
    
    CGContextSetStrokeColorWithColor(contex, self.rectangleColor.CGColor);
    
    CGContextStrokePath(contex);
}



#pragma mark - DrawSelec Image
- (void) drawSelectImage:(CGRect)rect
{
    CGFloat lineWidth = self.lineWidth;
    CGFloat offsetLine = lineWidth / 2; // Отстус в зависимости от ширины линии
    
    // Drawing code
    CGContextRef contex = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(contex, lineWidth);
    CGContextSetLineCap(contex, kCGLineCapRound);
    
    // Square
    CGContextMoveToPoint(contex, CGRectGetMinX(rect), CGRectGetMinY(rect)+offsetLine);             // First Line
    CGContextAddLineToPoint(contex, CGRectGetMaxX(rect), CGRectGetMinY(rect) + offsetLine);
    
    CGContextMoveToPoint(contex, CGRectGetMaxX(rect) - offsetLine, CGRectGetMinY(rect));           // Second Line
    CGContextAddLineToPoint(contex, CGRectGetMaxX(rect) - offsetLine, CGRectGetMaxY(rect));
    
    CGContextMoveToPoint(contex, CGRectGetMaxX(rect), CGRectGetMaxY(rect)-offsetLine);             // Third Line
    CGContextAddLineToPoint(contex, CGRectGetMinX(rect), CGRectGetMaxY(rect)-offsetLine);
    
    CGContextMoveToPoint(contex, CGRectGetMinX(rect) + offsetLine, CGRectGetMaxY(rect));           // Four Line
    CGContextAddLineToPoint(contex, CGRectGetMinX(rect) + offsetLine, CGRectGetMinY(rect));
    
    
    CGContextSetStrokeColorWithColor(contex, self.rectangleColor.CGColor);
    
    CGContextStrokePath(contex);
    
    
    //
    CGFloat lineSelectWidth = self.lineWidth / 2;
    CGContextSetLineWidth(contex, lineSelectWidth);
    CGContextSetLineCap(contex, kCGLineCapRound);
    
    NSInteger countWidth = (CGRectGetWidth(rect) + CGRectGetHeight(rect)) / lineSelectWidth;
    
    for (int offset=1; offset<countWidth; offset = offset + 3) {
        CGFloat posX = (offset * lineSelectWidth);
        CGContextMoveToPoint(contex, posX, CGRectGetMinY(rect));
        CGContextAddLineToPoint(contex, CGRectGetMinX(rect), posX);
    }
    
    
    
    CGContextSetStrokeColorWithColor(contex, [UIColor whiteColor].CGColor);
    
    CGContextStrokePath(contex);
    
    
    CGRect clearRect = CGRectMake(self.lineWidth, self.lineWidth, CGRectGetWidth(rect) - (self.lineWidth * 2), CGRectGetHeight(rect) - (self.lineWidth * 2));
    CGContextClearRect(contex, clearRect);
}



#pragma mark - Draw Grid
- (void) drawGrid:(CGRect)rect
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

}



- (void) createMoreHorizontalLines:(CGContextRef)contex andFrameRect:(CGRect)rect
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


- (void) createMoreVerticalLines:(CGContextRef)contex andFrameRect:(CGRect)rect
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



#pragma mark - Get
-(UIImage *)gridImage
{
    return [self createUIImageFromView:self];
}


-(UIImage *)rectangleImage
{
    return [self gridImage];
}


-(UIImage*) createUIImageFromView:(UIView *)view;
{
//    if (UIGraphicsBeginImageContextWithOptions != NULL)
//    {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 2.0f);
//    }
//    else
//    {
//        UIGraphicsBeginImageContext(view.frame.size);
//    }
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
