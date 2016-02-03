//
//  JsonFeedBack.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/28/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "Json.h"

@interface JsonFeedBack : Json
- (id) initWithFeedBackType:(NSInteger)feedBackType
                   andTitle:(NSString*)title
             andMessageText:(NSString*)message
                   andEmail:(NSString*)email;
@end
