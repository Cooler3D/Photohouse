//
//  AlbumListViewController.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 11/28/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHBaseTableViewController.h"

@class PrintData;

@interface AlbumListViewController : PHBaseTableViewController
- (void) showStyleListPrintData:(PrintData *)printData;
- (void) showSizeListPrintData:(PrintData *)printData;
- (void) showCoverListPrintData:(PrintData *)printData;
- (void) showUturnListPrintData:(PrintData *)printData;
@end
