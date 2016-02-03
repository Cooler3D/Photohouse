//
//  StyleTableViewCell.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/21/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StyleTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageStyleView;
@property (weak, nonatomic) IBOutlet UILabel *styleDisplayLabel;
@property (weak, nonatomic) IBOutlet UILabel *styleCountImageLabel;

@end
