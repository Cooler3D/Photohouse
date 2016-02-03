//
//  JsonCancelOrder.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/28/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "Json.h"

@interface JsonCancelOrder : Json
- (id) initJsonOrderID:(NSString *)order_id andUserID:(NSString *)user_id;
@end
