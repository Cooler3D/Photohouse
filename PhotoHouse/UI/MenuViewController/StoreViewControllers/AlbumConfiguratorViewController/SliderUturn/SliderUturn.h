//
//  SliderUturn.h
//  SliderTest
//
//  Created by Дмитрий Мартынов on 5/24/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PropUturn;
@protocol SliderUturnDelegate;

@interface SliderUturn : UISlider
- (id) initWithFrame:(CGRect)frame andUturns:(NSArray *)uturns andDelegate:(id<SliderUturnDelegate>)delegate;
@end


@protocol SliderUturnDelegate <NSObject>
@required
- (void) sliderUrurn:(SliderUturn *)slider  didChangeUturn:(PropUturn *)uturn;
@end
