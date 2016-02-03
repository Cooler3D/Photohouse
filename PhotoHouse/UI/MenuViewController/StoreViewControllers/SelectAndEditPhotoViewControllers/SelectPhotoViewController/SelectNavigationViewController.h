//
//  SelectNavigationViewController.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 4/22/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StoreItem;

@interface SelectNavigationViewController : UINavigationController
/** Передаем значения в выбор фотографий
 *@param storeItem покупка
 *@param unsavedUrls массив картинок(Nsstring), если заходим повторно
 *@param coreDataUse используется ли сейчас CoreData, если Yes - используется, No - не используется
 */
- (void) setRootStoreItem:(StoreItem *)storeItem andImages:(NSArray *)unsavedUrls andCoreDataUse:(BOOL)coreDataUse;
@end
