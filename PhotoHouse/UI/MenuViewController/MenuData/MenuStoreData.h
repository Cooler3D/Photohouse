//
//  MenuStoreData.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/25/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MenuStoreData : NSObject
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *imageIconName;
@property (strong, nonatomic) UIColor *colorStore;
@property (strong, nonatomic) NSString *storyboardNavigatorID;
//@property (assign, nonatomic) StoreType storeType;

@property (strong, nonatomic) NSString *price;
@end
