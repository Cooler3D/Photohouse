//
//  CartTableViewCell.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/3/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CartTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *countButton;

@property (weak, nonatomic) IBOutlet UIImageView *imageCartView;
@property (weak, nonatomic) IBOutlet UILabel *pcsLabel;
@end
