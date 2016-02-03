//
//  RequestAuth.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/24/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHRequest.h"

@interface RequestAuth : PHRequest
- (id) initAuthEMail:(NSString *)login andPasswordMD5:(NSString *)passwordMD5 __attribute__((deprecated("Use 'JSon'")));
@end
