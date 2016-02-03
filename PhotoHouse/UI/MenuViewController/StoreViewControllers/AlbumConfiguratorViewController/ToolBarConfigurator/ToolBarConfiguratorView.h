//
//  ToolBarConfigurator.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/25/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ToolBarConfiguratorDelegate;

@interface ToolBarConfiguratorView : UIView
@property (weak, nonatomic) id<ToolBarConfiguratorDelegate> delegate;

- (void) changePrice:(NSInteger)price;
@end


@protocol ToolBarConfiguratorDelegate <NSObject>

@required
- (void) toolBarConfigurator:(ToolBarConfiguratorView *)toolBar didActionNextButton:(NSString *)status;
@end

