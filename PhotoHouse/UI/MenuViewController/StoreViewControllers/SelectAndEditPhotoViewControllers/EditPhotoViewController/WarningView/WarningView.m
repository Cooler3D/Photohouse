//
//  WarningView.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/27/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "WarningView.h"

#import "PrintImage.h"


typedef enum {
    WarningViewMessageStatusOpened,
    WarningViewMessageStatusClosed
} WarningViewMessageStatus;



@interface WarningView ()
@property (weak, nonatomic) IBOutlet UIButton *openWarningButton;
@property (weak, nonatomic) IBOutlet UIButton *closeWarningButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (assign, nonatomic) WarningViewMessageStatus warningMessageStatus;   // Показывается ли тест
@end



@implementation WarningView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.warningMessageStatus = WarningViewMessageStatusOpened;
    [self configure];
}


- (void) checkImage:(PrintImage *)printImage
{
    
}



- (void) configure {
    //
    if (self.warningMessageStatus == WarningViewMessageStatusClosed) {
        [self.openWarningButton setHidden:YES];
        [self.closeWarningButton setHidden:NO];
        [self.messageLabel setHidden:YES];
    } else {
        [self.openWarningButton setHidden:NO];
        [self.closeWarningButton setHidden:YES];
        [self.messageLabel setHidden:NO];
    }
    
    
}


#pragma mark - Public
- (void) showWarningView {
    [self setHidden:NO];
    
    //self.warningMessageStatus = WarningViewMessageStatusOpened;
    //[self configure];
}

- (void) hideWarningView {
    [self setHidden:YES];
}



#pragma mark - Actions
- (IBAction)actionCloseButton:(UIButton *)sender {
    self.warningMessageStatus = WarningViewMessageStatusOpened;
    [self configure];
}
- (IBAction)actionOpenButton:(UIButton *)sender {
    self.warningMessageStatus = WarningViewMessageStatusClosed;
    [self configure];
}


@end
