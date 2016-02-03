//
//  HistoryOrderTableViewCell.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/16/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryOrderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageAvatarView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusTitleLabel;

@end
