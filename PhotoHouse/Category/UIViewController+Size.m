//
//  UIViewController+Size.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/11/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "UIViewController+Size.h"

@implementation UIViewController (Size)
- (CGSize) sizeViewController
{
    UIViewController *controller = self;
    
    CGFloat widthView = 0.0;
    CGFloat heightView = 0.0;
    
    switch (controller.interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            widthView = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
            heightView = MAX(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            widthView = MAX(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
            heightView = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
            break;
        case UIInterfaceOrientationUnknown:
            
            break;
    }
    
    CGSize size = CGSizeMake(widthView, heightView);
    return size;
}
@end
