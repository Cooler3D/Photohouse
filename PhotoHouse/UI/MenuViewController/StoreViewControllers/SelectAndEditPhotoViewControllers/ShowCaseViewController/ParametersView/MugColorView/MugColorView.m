//
//  MugColorView.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 07/04/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import "MugColorView.h"

#import "StoreItem.h"
#import "PropColor.h"
#import "PropType.h"


@interface MugColorView ()
@property (weak, nonatomic) IBOutlet UIImageView *currentImageView;
@property (weak, nonatomic) IBOutlet UIView *listColorsView;

@property (strong, nonatomic) StoreItem *storeItem;
@end



@implementation MugColorView

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
    [self hide];
}

- (void) configure:(StoreItem *)storeItem {
    // Current
    [self.currentImageView setImage:[UIImage imageNamed:storeItem.propType.selectPropColor.color]];
    
    // add buttons
    for (int i=0; i<storeItem.propType.colors.count; i++) {
        PropColor *color = [storeItem.propType.colors objectAtIndex:i];
        
        UIImage *backImage;
        if (i == 0) {
            backImage = [UIImage imageNamed:@"TShirtBackStart"];
        } else if (i == storeItem.propType.colors.count-1) {
            backImage = [UIImage imageNamed:@"TShirtBackEnd"];
        } else {
            backImage = [UIImage imageNamed:@"TShirtBackMiddle"];
        }
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0.f, i*30.f, 60.f, 30.f)];
        [button addTarget:self action:@selector(actionChooseSize:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:color.color] forState:UIControlStateNormal];
        [button setBackgroundImage:backImage forState:UIControlStateNormal];
        [self.listColorsView addSubview:button];
    }
}

-(void)setPrintDataStoreItem:(StoreItem *)storeItem withDelegate:(id<MugColorDelegate>)delegate
{
    _delegate = delegate;
    _storeItem = storeItem;
    
    [self configure:storeItem];
}


#pragma mark - Methods
- (void) hide {
    [self.listColorsView setHidden:YES];
}


#pragma mark - Actions
- (IBAction)actionOpenSizes:(UIButton *)sender {
    [self.listColorsView setHidden:NO];
}



- (IBAction)actionChooseSize:(UIButton *)sender {
    
    PropColor *currentColor;
    for (PropColor *color in self.storeItem.propType.colors) {
        if ([[UIImage imageNamed:color.color] isEqual:sender.imageView.image]) {
            currentColor = color;
        }
    }
    
    // Delegate
    [self.delegate cupColorView:self didSelectColor:currentColor];
    
    // Hide
    [self hide];
    
    //
    [self.currentImageView setImage:[UIImage imageNamed:currentColor.color]];
}

@end
