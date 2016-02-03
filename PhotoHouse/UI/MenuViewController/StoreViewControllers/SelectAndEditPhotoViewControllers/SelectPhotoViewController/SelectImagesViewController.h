//
//  ViewController.h
//  CollectionViewLayout
//
//  Created by Дмитрий Мартынов on 4/23/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StoreItem;

@interface SelectImagesViewController : UICollectionViewController

/** Данные для контроллера выбора фоток
 *@param storeItem выбранная покупка
 *@param unsavedUrls имена картинок в библиотеке, если открываем повторно
 *@param coreDataUse используется ли сейчас CoreData, если Yes - используется, No - не используется
 */
- (void) setStoreItemInit:(StoreItem *)storeItem andImages:(NSArray *)unsavedUrls andCoreDataUse:(BOOL)coreDataUse;
@end
