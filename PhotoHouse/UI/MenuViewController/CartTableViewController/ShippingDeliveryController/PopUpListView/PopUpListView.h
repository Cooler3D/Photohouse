//
//  EarlyInputView.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 10/10/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TypeInputAddress,
    TypeInputPhone,
    TypeInputCityDelivery,
    TypeInputTypeDelivery,
    TypeInputTypePayment
} TypeInput;

@protocol PopUpListDelegate;


@interface PopUpListView : UIView
@property (weak, nonatomic) id<PopUpListDelegate> delegate;

- (void) showTypesArray:(NSArray*)array withTypeInput:(TypeInput)typeInput;
//- (void) showDeliveryTypes:(NSArray *)array;
@end




@protocol PopUpListDelegate <NSObject>
@optional
- (void) popUpListView:(PopUpListView *)popUpView didSelectErlyInput:(NSString*)string withType:(TypeInput)typeInput;
@end

