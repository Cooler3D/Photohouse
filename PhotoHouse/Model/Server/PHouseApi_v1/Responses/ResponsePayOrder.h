//
//  ResponsePayOrder.h
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 26/01/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import "PHResponse.h"

@interface ResponsePayOrder : PHResponse
@property (strong, nonatomic, readonly) NSURL *payURL;
@end
