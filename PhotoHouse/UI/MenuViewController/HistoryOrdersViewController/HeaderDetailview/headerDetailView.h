//
//  headerDetailView.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/22/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HistoryOrder;

@interface headerDetailView : UIView
- (void) initWithHistoryOrder:(HistoryOrder *)order;
@end
