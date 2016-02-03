//
//  ToolPhotoView.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/28/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "ToolPhotoView.h"

@implementation ToolPhotoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

#pragma mark - Action
- (IBAction)actionToolAddPhoto:(UIButton *)sender {
    [self.delegate addPhoto];
}
- (IBAction)actionEditPhoto:(UIButton *)sender {
    [self.delegate editPhoto];
}

@end
