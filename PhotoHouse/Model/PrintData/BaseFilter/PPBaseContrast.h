//
//  PPBaseContrast.h
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 19/11/15.
//  Copyright © 2015 Мартынов Дмитрий. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPBaseContrast : NSObject
+ (UIImage*)contrastImage:(UIImage*)image withSaturation:(CGFloat)saturation andBrightness:(CGFloat)brightness andContrast:(CGFloat)contrast;
@end
