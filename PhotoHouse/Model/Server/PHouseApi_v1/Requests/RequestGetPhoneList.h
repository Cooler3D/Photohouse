//
//  RequestGetPhoneList.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/26/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHRequest.h"

@interface RequestGetPhoneList : PHRequest
- (id) initPhonelist __attribute__((deprecated("Use 'JSon'")));
@end
