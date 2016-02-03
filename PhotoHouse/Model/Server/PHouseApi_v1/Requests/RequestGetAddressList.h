//
//  RequestGetAddressList.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/26/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHRequest.h"

@interface RequestGetAddressList : PHRequest
- (id) initWithAddresslist __attribute__((deprecated("Use 'JSon'")));
@end
