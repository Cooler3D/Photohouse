//
//  ReguestRestorePass.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/6/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PHRequest.h"

@interface RequestRestorePass : PHRequest
- (id) initRestorePassWithEmail:(NSString *)email __attribute__((deprecated("Use 'JSon'")));
@end
