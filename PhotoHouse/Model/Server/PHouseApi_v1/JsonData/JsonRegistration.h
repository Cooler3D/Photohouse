//
//  JsonRegistration.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/28/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "Json.h"

@interface JsonRegistration : Json
-(id)initJsonRegistationPhotoHouseFirstName:(NSString *)firstname
                                andLastName:(NSString *)lastName
                                   andEmail:(NSString *)email
                               withPassword:(NSString *)password;

@end
