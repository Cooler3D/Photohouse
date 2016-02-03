//
//  PreviewImageTheme.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/13/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PrintImage;

@interface PreviewImageTheme : UIView
@property (nonatomic, readonly) UIImageView *previewImageView;



- (id)initWithFrame:(CGRect)frame
             target:(id)target
             action:(SEL)action
         printImage:(PrintImage*)printImage;
@end
