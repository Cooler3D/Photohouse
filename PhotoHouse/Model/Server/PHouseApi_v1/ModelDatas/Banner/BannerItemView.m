//
//  BannerItemView.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/22/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "BannerItemView.h"



@implementation BannerItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (id) initWithFrame:(CGRect)frame target:(id)target action:(SEL)action setBanner:(Banner *)banner 
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [self addGestureRecognizer:gesture];
        
        _banner = banner;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];//CGRectMake(2, 4, rect.size.width - 4, rect.size.height - 8)
    [imageView setImage:_banner.image];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:imageView];
}

@end
