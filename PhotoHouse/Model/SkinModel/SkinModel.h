//
//  PhotoModel.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/6/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface SkinModel : NSObject

/// Singleton
+ (SkinModel*) sharedManager;

/** Header for ViewController */
// Для первых ViewController-ов
- (UILabel*) headerForViewControllerWithTitle:(NSString*)title;
- (UIColor*) headerColorWithViewController;

// Для Detail, следующих
- (void) headerForDetailViewWithNavigationBar:(UINavigationBar*)navigationBar;
@end
