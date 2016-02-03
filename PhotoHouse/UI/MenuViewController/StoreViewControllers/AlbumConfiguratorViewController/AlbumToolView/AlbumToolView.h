//
//  AlbumToolView.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/12/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TypeConfiguratorStyle,      // PropStyle
    TypeConfiguratorSize,       // PropPage
    TypeConfiguratorCover,      // PropCover
    TypeConfiguratorPage        // PropPage
} TypeConfigurator;


@interface AlbumToolView : UIView
@property (assign, nonatomic, readonly) TypeConfigurator typeConfigutator;
@property (strong, nonatomic, readonly) id propObject;


- (id)initWithFrame:(CGRect)frame
             target:(id)target
             action:(SEL)action
         propObject:(id)propObject
        andSelected:(BOOL)selected;

-(BOOL)isSelected;

-(void) deselect;

- (void) selectTool;

/** Сравниваю PropObject, если сходится, то выделение поставится
 *@param propObject объект propObject для сравнения
 */
- (void) comparePropObject:(id)propObject;
@end
