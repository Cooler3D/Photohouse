//
//  RequestCancelOrder.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/23/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PHRequest.h"

@interface RequestCancelOrder : PHRequest
- (id) initWithOrderID:(NSString *)order_id andUserID:(NSString *)user_id __attribute__((deprecated("Use 'JSon'")));
@end
