//
//  LayoutsTableViewController.h
//  AlbumConstructor
//
//  Created by Дмитрий Мартынов on 4/28/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const LayoutChooseNotification;

extern NSString *const LayoutChooseKey;


@interface LayoutsTableViewController : UITableViewController
- (void) setLayoutsTemplate:(NSArray *)layouts;
@end
