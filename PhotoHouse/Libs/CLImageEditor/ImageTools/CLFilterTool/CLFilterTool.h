//
//  CLFilterTool.h
//
//  Created by sho yakushiji on 2013/10/19.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "CLImageToolBase.h"

@protocol CLFilterToolDelegate;

@interface CLFilterTool : CLImageToolBase
// Custom Methods
- (void) setupImage:(UIImage*)image andScroll:(UIScrollView*)scrollView;
- (void) updateImage:(UIImage*)image;

// Применяем фильтр по имени
- (void) applyFilterWithName:(NSString*)name;

@property (weak, nonatomic) id<CLFilterToolDelegate> delegate;
@end





@protocol CLFilterToolDelegate <NSObject>
@required
- (void) clFilterToolStartApplyFilter:(UIImage*)image;
- (void) clFilterToolApplyFilterImage:(UIImage*)image;
- (void) clFilterToolDidLastActionFilter:(CLImageToolInfo*)info;
@end