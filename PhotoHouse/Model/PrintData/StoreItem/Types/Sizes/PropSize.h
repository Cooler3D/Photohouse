//
//  PropSize.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/27/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PropSize : NSObject
@property (strong, nonatomic, readonly) NSString *sizeName;
@property (assign, nonatomic, readonly) NSUInteger price;

- (id) initSize:(NSString *)size andPrice:(NSInteger)price;
@end
