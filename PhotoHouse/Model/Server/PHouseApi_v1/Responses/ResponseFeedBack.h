//
//  ResponseFeedBack.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/8/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PHResponse.h"

typedef enum {
    FeedBackError = 1,
    FeedBackUpdate = 2,
    FeedBackOther = 3
} FeedBackType;

@interface ResponseFeedBack : PHResponse

@end
