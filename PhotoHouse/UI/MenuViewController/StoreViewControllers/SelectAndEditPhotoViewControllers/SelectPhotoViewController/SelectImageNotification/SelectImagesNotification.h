//
//  SelectImageNotification.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/10/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

// Notification
extern NSString *const SelectAllImagesSelectCompleteNotification;
extern NSString *const SelectAllImagesSelectCancelNotification;

// Key Notification
extern NSString *const SelectAllImagesKey;
extern NSString *const SelectAllRemoveImagesKey;


@interface SelectImagesNotification : NSObject

@end
