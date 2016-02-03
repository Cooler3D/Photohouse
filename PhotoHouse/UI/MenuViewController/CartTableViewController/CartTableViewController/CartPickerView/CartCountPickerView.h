//
//  CartCountPickerView.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/4/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CartCountDelegate;



@interface CartCountPickerView : UIView
@property (weak, nonatomic) id<CartCountDelegate> delegate;

- (void) showActualNumber:(NSUInteger)index;
@end




@protocol CartCountDelegate <NSObject>
@required
- (void) cartCountCancel:(CartCountPickerView*)picker;
- (void) cartPicker:(CartCountPickerView*)picker countOk:(NSInteger)count;

@end