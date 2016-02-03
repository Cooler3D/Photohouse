//
//  ShowCaseViewController.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/28/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHBaseViewController.h"

@class PrintData;
@class StoreItem;

@interface ShowCaseViewController : PHBaseViewController
/*! Устанавливаем несохраненные printData
 *@param printData идентификатор покупки, не сохраненный
 */
- (void) setUnsavedPrintDataStore:(PrintData *)printData;


/*! Устанавливаем StoreItem, если создаем с нуля
 *@param storeItem идентификатор покупки
 */
- (void) setPurshaseStoreItem:(StoreItem *)storeItem;


/// Передаем картинки для сохранения
/*! Передаем картинки для сохранения, используется для фотопечати
 *@param storeItem идентификатор покупки
 *@param images массив картинок [PrintImage]
 */
- (void) setPhotoPrintItem:(StoreItem *)storeItem andSelectedImages:(NSArray *)images;
@end
