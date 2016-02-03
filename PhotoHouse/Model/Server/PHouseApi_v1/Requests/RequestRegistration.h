//
//  RequestRegistration.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/27/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHRequest.h"

@interface RequestRegistration : PHRequest
- (id)initWithRegistationPhotoHouseFirstName:(NSString *)firstname
                                 andLastName:(NSString *)lastName
                                    andEmail:(NSString *)email
                                withPassword:(NSString *)password __attribute__((deprecated("Use 'JSon'")));
@end
