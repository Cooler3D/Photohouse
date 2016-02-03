//
//  ResponseRegistration.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/29/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHResponse.h"

@interface ResponseRegistration : PHResponse
@property (strong, nonatomic, readonly) NSString *id_user;
@property (strong, nonatomic, readonly) NSString *firstname;
@property (strong, nonatomic, readonly) NSString *lastname;
@property (strong, nonatomic, readonly) NSString *email;
@property (strong, nonatomic, readonly) NSString *password;
@property (strong, nonatomic, readonly) NSString *regdate;
@property (strong, nonatomic, readonly) NSString *group_id;
@property (strong, nonatomic, readonly) NSString *group_name;
@property (strong, nonatomic, readonly) NSString *access;
@end
