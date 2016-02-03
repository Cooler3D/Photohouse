//
//  CustomProgressView.m
//  ProgreessCustom
//
//  Created by Дмитрий Мартынов on 11/12/14.
//  Copyright (c) 2014 Individual. All rights reserved.
//

#import "CustomProgressView.h"
#import "CERoundProgressView.h"

@interface CustomProgressView ()
@property (weak, nonatomic) IBOutlet CERoundProgressView *detailProgressView;
@property (weak, nonatomic) IBOutlet CERoundProgressView *mainProgressView;
@end



@implementation CustomProgressView

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
    [self configure];
}

- (void) configure {
    UIColor *mainColor = [UIColor whiteColor];//[UIColor colorWithRed:48/255.f green:162/255.f blue:208/255.f alpha:1.f];//[UIColor whiteColor];
    UIColor *detailColor = mainColor;//[UIColor whiteColor];
    
    [self.mainProgressView setTintColor:mainColor];
    [self.detailProgressView setTintColor:detailColor];
    
    self.mainProgressView.trackColor = [UIColor colorWithRed:6/255.f green:28/255.f blue:45/255.f alpha:1.f];//[UIColor grayColor];
    self.detailProgressView.trackColor = [UIColor colorWithRed:6/255.f green:28/255.f blue:45/255.f alpha:1.f];//[UIColor grayColor];
    
    self.mainProgressView.startAngle = (3.0*M_PI)/2.0;
    self.detailProgressView.startAngle = (3.0*M_PI)/2.0;
}


#pragma mark - Public
- (void) setProgressMain:(CGFloat)progress {
    [self.mainProgressView setProgress:progress];
}
- (void) setProgressDetail:(CGFloat)progress {
    [self.detailProgressView setProgress:progress];
}

@end
