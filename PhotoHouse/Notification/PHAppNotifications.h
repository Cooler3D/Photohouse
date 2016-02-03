//
//  NotificationPH.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 11/18/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
// Notification
extern NSString *const BadjeDidChangeCartCountNotification;

// Key
extern NSString *const BadjeDidChangeCartCountKey;



// Segue
extern NSString *const GoToCartSegueNotification;
extern NSString *const GoToHistorySegueNotification;
extern NSString *const GoToStoreSegueNotification;


@interface PHAppNotifications : NSObject

@end
