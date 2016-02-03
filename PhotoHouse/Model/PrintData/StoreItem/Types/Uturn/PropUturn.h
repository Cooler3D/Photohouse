//
//  PropUturn.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/27/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PropUturn : NSObject
@property (strong, nonatomic, readonly) NSString *uturn;
@property (assign, nonatomic, readonly) NSUInteger price;

- (id) initUturn:(NSString *)uturn andPrice:(NSInteger)price;
@end
