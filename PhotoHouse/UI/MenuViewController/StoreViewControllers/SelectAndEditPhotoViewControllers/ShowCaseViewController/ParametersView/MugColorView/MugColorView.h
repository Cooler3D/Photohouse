//
//  MugColorView.h
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 07/04/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StoreItem;
@class PropColor;
@protocol MugColorDelegate;


@interface MugColorView : UIView
@property (weak, nonatomic) id<MugColorDelegate> delegate;

- (void) setPrintDataStoreItem:(StoreItem *)storeItem withDelegate:(id<MugColorDelegate>)delegate;
@end


@protocol MugColorDelegate <NSObject>
@required
- (void) cupColorView:(MugColorView*)view didSelectColor:(PropColor *)color;
@end
