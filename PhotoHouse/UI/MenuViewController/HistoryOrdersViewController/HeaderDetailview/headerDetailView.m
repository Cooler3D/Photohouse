//
//  headerDetailView.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/22/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "headerDetailView.h"

#import "HistoryOrder.h"
#import "PersonOrderInfo.h"

@interface headerDetailView ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *deliveryTextView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UIImageView *purchaseImageView;

@end

@implementation headerDetailView

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
#pragma mark - Methods Public
- (void) initWithHistoryOrder:(HistoryOrder *)order
{
    [self.purchaseImageView setImage:[order iconOrderImage]];
    [self.statusImageView setImage:[order statusOrderImage]];
    //
    self.dateLabel.text = order.personInfo.dateString;

    NSString *fullName = [order.personInfo.fullName stringByReplacingPercentEscapesUsingEncoding:NSWindowsCP1251StringEncoding];
    NSString *descriptionUser = [order.personInfo.deliveryComment stringByReplacingPercentEscapesUsingEncoding:NSWindowsCP1251StringEncoding];
    self.deliveryTextView.text =[NSString stringWithFormat:@"%@ %@, %@", fullName, order.personInfo.phone, descriptionUser];
}
@end
