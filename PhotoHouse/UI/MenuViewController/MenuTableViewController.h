//
//  MenuTableViewController.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/5/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MDMenuSlideTypeClosed,
    MDMenuSlideTypeOpened
} MDMenuSlideType;


extern NSString *const Menu_StoryboardID;
extern NSString *const Store_StoryboardID;
extern NSString *const Cart_StoryboardID;


/// Notification
extern NSString *const ShopCartItemsCountNotification;
extern NSString *const MainMenuSelectionNotification;

extern NSString *const ShopCartItemsCountKey;
extern NSString *const MainMenuSelectionKey;



@interface MenuTableViewController : UITableViewController

@end
