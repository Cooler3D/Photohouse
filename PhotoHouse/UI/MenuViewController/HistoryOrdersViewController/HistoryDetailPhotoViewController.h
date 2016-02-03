//
//  HistoryDetailViewController.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 10/1/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHBaseViewController.h"
@class PrintData;

@interface HistoryDetailPhotoViewController : PHBaseViewController
- (void) setPrintDataOrder:(PrintData *)printData;
@end
