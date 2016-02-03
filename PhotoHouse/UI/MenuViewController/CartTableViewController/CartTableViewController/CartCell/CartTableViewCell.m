//
//  CartTableViewCell.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/3/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "CartTableViewCell.h"

@implementation CartTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
