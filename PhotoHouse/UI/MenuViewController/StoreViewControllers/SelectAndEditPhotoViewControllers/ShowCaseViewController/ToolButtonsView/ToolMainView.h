//
//  ToolMainView.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/28/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    FlipToRight,
    FlipToLeft
} FlipToOrientation;


@protocol ToolShowCaseDelegate;


@interface ToolMainView : UIView
@property (weak, nonatomic) id<ToolShowCaseDelegate> delegate;
@end


@protocol ToolShowCaseDelegate <NSObject>
@required
- (void) addPhoto;
- (void) editPhoto;
- (void) rotatePhoto:(FlipToOrientation)orientation;
@end
