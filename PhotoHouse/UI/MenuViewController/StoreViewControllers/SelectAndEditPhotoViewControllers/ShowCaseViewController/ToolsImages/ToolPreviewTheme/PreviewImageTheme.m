//
//  PreviewImageTheme.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/13/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PreviewImageTheme.h"

#import "PrintImage.h"

@implementation PreviewImageTheme
{
    @private
    PrintImage *_printImage;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat W = frame.size.width;
        
        _previewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, W-20, W-10)];
        _previewImageView.clipsToBounds = YES;
        _previewImageView.layer.cornerRadius = 5;
        _previewImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_previewImageView];
    }
    return self;
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action printImage:(PrintImage *)printImage
{
    self = [self initWithFrame:frame];
    if(self){
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [self addGestureRecognizer:gesture];
        
        _printImage = printImage;
        [_previewImageView setImage:printImage.iconPreviewImage];
        
    }
    return self;
}


@end
