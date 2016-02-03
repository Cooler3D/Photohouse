//
//  TShirtSizeView.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/29/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StoreItem;
@class PropSize;
@protocol TShirtSizeDelegate;


@interface TShirtSizeView : UIView
@property (weak, nonatomic) id<TShirtSizeDelegate> delegate;
- (void) setPrintDataStoreItem:(StoreItem *)storeItem withDelegate:(id<TShirtSizeDelegate>)delegate;
@end



@protocol TShirtSizeDelegate <NSObject>
@required
- (void) tshirt:(TShirtSizeView *)tshirt didChangeSize:(PropSize *)size;
@end



