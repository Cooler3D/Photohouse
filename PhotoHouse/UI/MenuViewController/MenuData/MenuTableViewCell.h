//
//  MenuTableViewCell.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/22/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIView *selectedCellView;
@property (weak, nonatomic) IBOutlet UILabel *cartCount;
@property (weak, nonatomic) IBOutlet UIView *cartView;
@property (weak, nonatomic) IBOutlet UIImageView *cartBadjeImageView;

@end
