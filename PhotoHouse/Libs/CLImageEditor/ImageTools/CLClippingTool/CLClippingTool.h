//
//  CLClippingTool.h
//
//  Created by sho yakushiji on 2013/10/18.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "CLImageToolBase.h"



@protocol CLClippingToolDelegate;


@interface CLClippingTool : CLImageToolBase
@property (weak, nonatomic) id<CLClippingToolDelegate> delegate;

- (void) setupWithImageView:(UIImageView*)imageView andDelegate:(id<CLClippingToolDelegate>)delegate;
- (void) setupMemberRect:(CGRect)rect;

- (void)executeWithCustomCompletionBlock:(void (^)(UIImage *image, CGRect rectOriginal, CGRect cropRectSetting))completionBlock;
@end





@protocol CLClippingToolDelegate <NSObject>
@required
- (void) clClippingTool:(CLClippingTool*)tool didMoveSelectGridEnd:(CGRect)rect;
@end