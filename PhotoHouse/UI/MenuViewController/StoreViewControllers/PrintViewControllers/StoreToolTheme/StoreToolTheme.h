//
//  StoreToolTheme.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 4/20/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StoreItem;

@interface StoreToolTheme : UIView
/*! Иницализируем одну покупку для магазина
 *@param frame рамка для показа картинки и текста
 *@param target контроллер, куда будет вызываться собвтия нажатия
 *@param action событи
 *@param storeItem текущая покупка
 */
- (id)initWithFrame:(CGRect)frame
             target:(id)target
             action:(SEL)action
          storeItem:(StoreItem*)storeItem;


- (StoreItem *) getSelectStoreItem;
@end
