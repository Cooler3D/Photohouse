//
//  PPBaseFilter.h
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 18/11/15.
//  Copyright © 2015 Мартынов Дмитрий. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPBaseFilter : NSObject
+ (UIImage*)applyFilter:(UIImage*)image withFilterName:(NSString *)filterName;

+ (NSArray *)allFilters;
@end
