//
//  PropCover.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/27/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PropCover : NSObject
@property (strong, nonatomic, readonly) NSString *cover;
@property (assign, nonatomic, readonly) NSUInteger price;

- (id) initCover:(NSString *)cover andPrice:(NSInteger)price;
@end
