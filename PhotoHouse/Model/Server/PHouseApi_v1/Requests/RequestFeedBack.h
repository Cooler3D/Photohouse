//
//  RequestFeedBack.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/8/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PHRequest.h"

@interface RequestFeedBack : PHRequest
- (id) initWithFeedBackType:(NSInteger)feedBackType
                   andTitle:(NSString*)title
             andMessageText:(NSString*)message
                   andEmail:(NSString*)email __attribute__((deprecated("Use 'JSon'")));
@end
