//
//  TShirtSizeView.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/29/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "TShirtSizeView.h"

#import "StoreItem.h"
#import "PropSize.h"
#import "PropType.h"


@interface TShirtSizeView ()
@property (weak, nonatomic) IBOutlet UILabel *currentSizeLabel;
@property (weak, nonatomic) IBOutlet UIView *listSizesView;

@property (strong, nonatomic) StoreItem *storeItem;
@end




@implementation TShirtSizeView

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
    [self.currentSizeLabel setText:storeItem.propType.selectPropSize.sizeName];
    
    // add buttons
    for (int i=0; i<storeItem.propType.sizes.count; i++) {
        PropSize *size = [storeItem.propType.sizes objectAtIndex:i];
        
        UIImage *backImage;
        if (i == 0) {
            backImage = [UIImage imageNamed:@"TShirtBackStart"];
        } else if (i == storeItem.propType.sizes.count-1) {
            backImage = [UIImage imageNamed:@"TShirtBackEnd"];
        } else {
            backImage = [UIImage imageNamed:@"TShirtBackMiddle"];
        }
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0.f, i*30.f, 60.f, 30.f)];
        [button addTarget:self action:@selector(actionChooseSize:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:size.sizeName forState:UIControlStateNormal];
        [button setBackgroundImage:backImage forState:UIControlStateNormal];
        [self.listSizesView addSubview:button];
    }
}

-(void)setPrintDataStoreItem:(StoreItem *)storeItem withDelegate:(id<TShirtSizeDelegate>)delegate
{
    _delegate = delegate;
    _storeItem = storeItem;
    
    [self configure:storeItem];
}


#pragma mark - Methods
- (void) hide {
    [self.listSizesView setHidden:YES];
}


#pragma mark - Actions
- (IBAction)actionOpenSizes:(UIButton *)sender {
    [self.listSizesView setHidden:NO];
}



- (IBAction)actionChooseSize:(UIButton *)sender {
    
    PropSize *currentSize;
    for (PropSize *size in self.storeItem.propType.sizes) {
        if ([size.sizeName isEqualToString:sender.titleLabel.text]) {
            currentSize = size;
        }
    }
    
    // Delegate
    [self.delegate tshirt:self didChangeSize:currentSize];
    
    // Hide
    [self hide];
    
    //
    [self.currentSizeLabel setText:currentSize.sizeName];
}


@end
