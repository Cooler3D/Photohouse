//
//  ResponseAuth.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/24/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHResponse.h"

@interface ResponseAuth : PHResponse
@property (strong, nonatomic, readonly) NSString *id_user;
@property (strong, nonatomic, readonly) NSString *firstname;
@property (strong, nonatomic, readonly) NSString *lastname;
@property (strong, nonatomic, readonly) NSString *email;
@property (strong, nonatomic, readonly) NSString *passwordHash;
@property (strong, nonatomic, readonly) NSString *regdate;
@property (strong, nonatomic, readonly) NSString *group_id;
@property (strong, nonatomic, readonly) NSString *group_name;
@property (strong, nonatomic, readonly) NSString *access;

- (id) initWithIdUser:(NSString *)idUser
      andPasswordHash:(NSString *)passwordHash
         andFirstName:(NSString *)firstName
          andLastName:(NSString *)lastName
             andEmail:(NSString *)email
           andRegDate:(NSString *)regDate
           andGroupID:(NSString *)groupID
         andGroupName:(NSString *)groupName
            andAccess:(NSString *)access;


- (id) initWitParseData:(NSData *)data andPasswordHash:(NSString *)passwordHash;

/** Выход из системы и стирание данных профиля из CoreData
 */
- (void) logount;
@end
