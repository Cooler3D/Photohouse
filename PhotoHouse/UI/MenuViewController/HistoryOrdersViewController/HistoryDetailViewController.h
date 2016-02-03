//
//  HistoryOrderDetailTableViewController.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/22/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHBaseTableViewController.h"
extern NSString *const HistoryMainReloadNotification;

@class HistoryOrder;

@interface HistoryDetailViewController : PHBaseTableViewController
- (void) setHistoryOrder:(HistoryOrder *) order;
@end
