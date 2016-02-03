//
//  ToolTheme.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/9/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "ToolIconTheme.h"

#import "PrintImage.h"

@implementation ToolIconTheme
{
    @private
    UIImageView *_selectedView;
    PrintImage *_printImage;
    UIImageView *_iconView;
    BOOL _selected;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        CGFloat W = CGRectGetWidth(frame);
//                _iconView = [[UIImageView alloc] initWithFrame:frame/*CGRectMake(10, 5, W-20, W-10)*/];
//        //_iconView.clipsToBounds = YES;
//        //_iconView.layer.cornerRadius = 5;
//        //_iconView.contentMode = UIViewContentModeScaleAspectFill;
//        [self addSubview:_iconView];
//        
//        
//        UIView *selectView = [[UIView alloc] initWithFrame:frame/*CGRectMake(8, 3, W-16, W-6)*/];
//        [selectView setBackgroundColor:[UIColor colorWithRed:63/255.f green:128/255.f blue:186/255.f alpha:1.f]];
//        //[selectView setHidden:YES];
//        //[selectView.layer setCornerRadius:5.f];
//        //[self addSubview:selectView];
//        //_selectedView = selectView;
    }
    return self;

}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    
    //CGFloat W = CGRectGetWidth(rect);
    
    _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(rect), 2.f, CGRectGetWidth(rect), CGRectGetHeight(rect))];
    //_iconView.clipsToBounds = YES;
    //_iconView.layer.cornerRadius = 5;
    //_iconView.contentMode = UIViewContentModeScaleAspectFill;
    [_iconView setImage:_printImage.iconPreviewImage];
    [self addSubview:_iconView];
    
    
    
    UIImageView *selectView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_iconView.bounds) / 4,
                                                                            CGRectGetHeight(_iconView.bounds) / 4,
                                                                            CGRectGetMidX(_iconView.bounds),
                                                                            CGRectGetMidY(_iconView.bounds))];
//    [selectView setBackgroundColor:[UIColor colorWithRed:63/255.f green:128/255.f blue:186/255.f alpha:1.f]];
    [selectView setHidden:YES];
    [selectView setImage:[UIImage imageNamed:@"pageToolFull"]];
    [selectView setContentMode:UIViewContentModeScaleAspectFit];
    //[selectView.layer setCornerRadius:5.f];
//    [selectView setAlpha:0.f];
    [self addSubview:selectView];
    _selectedView = selectView;
    
    _selected = NO;

}


-(id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action printImage:(PrintImage *)printImage
{
    self = [super initWithFrame:frame];
    if(self) {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [self addGestureRecognizer:gesture];
        
        _printImage = printImage;
        //[_iconView setImage:printImage.iconPreviewImage];
        
    }
    return self;
}




#pragma mark - Public
- (void) selectedImage
{
    [_selectedView setHidden:NO];
    [_iconView setAlpha:0.5f];
}


- (void) deselectedImage
{
    [_selectedView setHidden:YES];
    
    [_iconView setAlpha:1.f];
}

- (BOOL) isSelected
{
    return !_selectedView.hidden;
}

-(void)updateIcon {
    [_iconView setImage:self.printImage.iconPreviewImage];
}


- (UIImage *)previewImage
{
    return _printImage.previewImage;
}


/*! Получаем тукущую PrintImage
 @return возвращаем PrintImage
 */
- (PrintImage *) printImage
{
    return _printImage;
}
@end
