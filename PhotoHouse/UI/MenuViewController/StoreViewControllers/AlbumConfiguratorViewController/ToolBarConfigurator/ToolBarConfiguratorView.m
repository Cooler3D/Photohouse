//
//  ToolBarConfigurator.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/25/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "ToolBarConfiguratorView.h"

@interface ToolBarConfiguratorView ()
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@end


@implementation ToolBarConfiguratorView

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


-(IBAction)actionNextbutton:(id)sender
{
    [self.delegate toolBarConfigurator:self didActionNextButton:nil];
}


-(void)changePrice:(NSInteger)price
{
    NSString *priceText = NSLocalizedString(@"price", nil);
    NSString *valute = NSLocalizedString(@"RUB", nil);
    [self.priceLabel setText:[NSString stringWithFormat:@"%@ %li %@.", priceText, (long)price, valute]];

    [self.nextButton setTitle:NSLocalizedString(@"next", nil) forState:UIControlStateNormal];
}
@end
