//
//  PropColor.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/9/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PropColor : NSObject
@property (strong, nonatomic, readonly) NSString *color;
@property (assign, nonatomic, readonly) NSUInteger price;

- (id) initColor:(NSString *)color andPrice:(NSInteger)price;
@end
