//
//  GetBannersRequest.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/22/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHRequest.h"

@interface RequestGetBanners : PHRequest
- (id) initBanners __attribute__((deprecated("Use 'JSon'")));
@end
