//
//  ResponseAuth.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/24/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "ResponseAuth.h"
#import "CoreDataProfile.h"

@implementation ResponseAuth
-(id)initWitParseData:(NSData *)data
{
    self = [super init];
    if (self) {
        [self parse:data];
    }
    return self;
}

-(id)initWitParseData:(NSData *)data andPasswordHash:(NSString *)passwordHash
{
    self = [super init];
    if (self) {
        [self parse:data];
        _passwordHash = passwordHash;
    }
    return self;
}

- (void) parse:(NSData *)response {
    // Check
    NSDictionary *result = [self hasErrorResponce:response];
    if (self.error != nil) {
        NSLog(@"error: %@", self.error);
        return;
    }
    
    // Read
    NSDictionary *user = [result objectForKey:@"auth"];
    [self readUser:user];
}


- (id) initWithIdUser:(NSString *)idUser
       andPasswordHash:(NSString *)passwordHash
         andFirstName:(NSString *)firstName
          andLastName:(NSString *)lastName
             andEmail:(NSString *)email
           andRegDate:(NSString *)regDate
           andGroupID:(NSString *)groupID
         andGroupName:(NSString *)groupName
            andAccess:(NSString *)access
{
    self = [super init];
    if (self)
    {
        _id_user    = idUser;
        _passwordHash= passwordHash;
        _firstname  = firstName;
        _lastname   = lastName;
        _email      = email;
        _regdate    = regDate;
        _group_id   = groupID;
        _group_name = groupName;
        _access     = access;
    }
    
    return self;
}




- (void) readUser:(NSDictionary *)dictionary {
    NSString *name = [[dictionary objectForKey:@"firstname"] stringByReplacingPercentEscapesUsingEncoding:NSWindowsCP1251StringEncoding];
    NSString *last = [[dictionary objectForKey:@"lastname"] stringByReplacingPercentEscapesUsingEncoding:NSWindowsCP1251StringEncoding];
    
    _id_user    = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"user_id"]];
    _firstname  = name;//[dictionary objectForKey:@"firstname"];
    _lastname   = last;//[dictionary objectForKey:@"lastname"];
    _email      = [dictionary objectForKey:@"email"];
    _passwordHash= [dictionary objectForKey:@"password"];
    _regdate    = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"reg_time"]];
    _group_id   = [dictionary objectForKey:@"group_id"];
    _group_name = [dictionary objectForKey:@"group_name"];
    _access     = [dictionary objectForKey:@"access"];
    
    
    // Save CoreData
    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
    [coreProfile saveProfile:self];
}



- (void)logount
{
    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
    [coreProfile logount];
}

@end
