//
//  ToolAlbumView.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 10/15/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "ToolAlbumView.h"

@implementation ToolAlbumView

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

- (IBAction)actionEditPhoto:(UIButton *)sender {
    [self.delegate editPhoto];
}

@end
