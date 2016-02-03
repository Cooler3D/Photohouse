//
//  AlbumConfiguratorTableViewController.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 11/27/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHBaseViewController.h"

@class StoreItem;

@interface AlbumConfiguratorViewController : PHBaseViewController
- (void) setStoreItemInit:(StoreItem *)storeItem;
@end
