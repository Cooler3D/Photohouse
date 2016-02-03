//
//  RequestPayOrder.h
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 26/01/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import "PHRequest.h"

@interface RequestPayOrder : PHRequest
- (id) initWithOrderID:(NSString *)order_id __attribute__((deprecated("Use 'JSon'")));
@end
