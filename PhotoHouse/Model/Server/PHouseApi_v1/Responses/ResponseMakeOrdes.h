//
//  ResponseMakeOrdes.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/8/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PHResponse.h"

@interface ResponseMakeOrdes : PHResponse
@property (strong, nonatomic, readonly) NSURL *payUrl;
@end
