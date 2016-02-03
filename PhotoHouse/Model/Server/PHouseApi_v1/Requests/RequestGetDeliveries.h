//
//  ReqiestGetDeliveries.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/24/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHRequest.h"

@interface RequestGetDeliveries : PHRequest
- (id) initRequestWithDeliveries __attribute__((deprecated("Use 'JSon'")));
@end
