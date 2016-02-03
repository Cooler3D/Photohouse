//
//  StoreToolTheme.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 4/20/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "StoreToolTheme.h"

#import "StoreItem.h"
#import "PropType.h"
#import "PropStyle.h"


@implementation StoreToolTheme
{
@private
    UIView *_selectedView;
    StoreItem *_storeItem;
    UIImageView *_iconView;
    UILabel *_label;
    UILabel *_priceLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
    
        //
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 17.f, CGRectGetWidth(frame), CGRectGetHeight(frame) - 25.f)];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_iconView];
       
        
        //
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, CGRectGetMaxY(frame)-35.f, CGRectGetWidth(frame), 36.f)];
        [label setNumberOfLines:2];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont fontWithName:@"SegoeUI-Bold" size:12.f]];
        [label setTextAlignment:NSTextAlignmentCenter];
        //NSLog(@"Font: %@", [UIFont fontNamesForFamilyName:@"Segoe UI"]);
        [self addSubview:label];
        _label = label;
        
        //
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, CGRectGetMinY(label.frame) + 21.f, CGRectGetWidth(frame), 36.f)];
        [priceLabel setNumberOfLines:2];
        [priceLabel setFont:[UIFont fontWithName:@"SegoeUI-Light" size:10.f]];
        [priceLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:priceLabel];
        _priceLabel = priceLabel;

    }
    return self;
}

-(NSString *)description {
    return @"StoreToolTheme";
}


-(id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action storeItem:(StoreItem *)storeItem
{
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [self addGestureRecognizer:gesture];
        
        _storeItem = storeItem;
        [_iconView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_album_%@", storeItem.propType.name]]];
        [_iconView setBackgroundColor:[UIColor redColor]];
        [_label setText:NSLocalizedString(storeItem.propType.name, nil)];
        
//        if ([storeItem.purchaseID integerValue] == PhotoHousePrintAlbum) {
//            NSString *nameType = storeItem.propType.name;
//            [_label setText:NSLocalizedString(nameType, nil)];
//        } else {
            [_priceLabel setText:[NSString stringWithFormat:@"%li RUB", (long)storeItem.price]];
//        }
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    
    UIView *view = [[UIView alloc] initWithFrame:rect];
    [view setBackgroundColor:[UIColor yellowColor]];
    [view setUserInteractionEnabled:YES];
    [view setOpaque:YES];
    [self addSubview:view];
}*/



- (StoreItem *) getSelectStoreItem
{
    return _storeItem;
}

@end
