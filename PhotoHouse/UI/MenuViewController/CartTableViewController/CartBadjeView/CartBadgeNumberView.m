//
//  MDBadgeNumberView.m
//  DovezuClient2
//
//  Created by Мартынов Дмитрий on 02/08/14.
//  Copyright (c) 2014 Dmitriy. All rights reserved.
//

#import "CartBadgeNumberView.h"

@implementation CartBadgeNumberView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef contex = UIGraphicsGetCurrentContext();
    UIColor *circleColor = [UIColor colorWithRed:208/255.f green:49/255.f blue:53/255.f alpha:1.f];
    CGContextSetFillColorWithColor(contex, circleColor.CGColor);//[UIColor redColor]
    
    CGContextAddEllipseInRect(contex, rect);
    
    CGContextFillPath(contex);
    
    
    // Text
    NSString *text = [NSString stringWithFormat:@"%li", (long)self.number];
    
    UIFont *font = [UIFont systemFontOfSize:14.f];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor],    NSForegroundColorAttributeName,
                                font,                   NSFontAttributeName, nil];
    
    
    
    CGSize sizeText = [text sizeWithAttributes:attributes];
    //CGSize sizeText = [text sizeWithFont:font];
    
    CGPoint point = CGPointMake((CGRectGetWidth(self.frame) - sizeText.width) / 2,
                                (CGRectGetHeight(self.frame) - sizeText.height) / 2);
    
    [text drawAtPoint:point withAttributes:attributes];
    //[text drawAtPoint:point withFont:font];
}



@end
